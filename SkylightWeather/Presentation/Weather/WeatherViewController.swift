//
//  WeatherViewController.swift
//  SkylightWeather
//

import UIKit
import SwiftUI
import Observation

@MainActor
final class WeatherViewController: UIViewController {

    weak var coordinator: (any WeatherViewControllerCoordinating)?

    private let viewModel = WeatherViewModel()
    private let appSettings = AppSettings.shared

    private let contentContainer = UIView()
    private var hostingController: UIHostingController<WeatherHostedContent>?
    private var lastObservedLanguageCode: String?
    private var lastNavigationSourceTitle: String?
    private var observationUpdateTask: Task<Void, Never>?
    private var refreshThrottleTask: Task<Void, Never>?
    private var nextAllowedRefreshAt: Date = .distantPast

    private lazy var refreshBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(refreshTapped)
        )
        item.accessibilityIdentifier = "nav_refresh_button"
        return item
    }()

    private lazy var sourceBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(
            image: UIImage(systemName: "location.magnifyingglass"),
            menu: sourceMenu()
        )
        item.accessibilityIdentifier = "nav_source_button"
        return item
    }()

    private lazy var settingsBarButtonItem: UIBarButtonItem = {
        let item = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(settingsTapped)
        )
        item.accessibilityIdentifier = "nav_settings_button"
        return item
    }()

    private var quickCities: [String] {
        [
            appSettings.string(.quickCityMoscow),
            appSettings.string(.quickCitySaintPetersburg),
            appSettings.string(.quickCityKazan),
            appSettings.string(.quickCityNovosibirsk),
            appSettings.string(.quickCitySochi)
        ]
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        applyAppearance()
        setupNavigationItems()
        lastObservedLanguageCode = appSettings.languageCode
        observeViewModel()
        viewModel.loadWeather()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if isMovingFromParent || isBeingDismissed {
            observationUpdateTask?.cancel()
            observationUpdateTask = nil
            refreshThrottleTask?.cancel()
            refreshThrottleTask = nil
            coordinator?.setGlobalLoadingVisible(false)
            viewModel.cancelLoading()
            hostingController?.willMove(toParent: nil)
            hostingController?.view.removeFromSuperview()
            hostingController?.removeFromParent()
            hostingController = nil
        }
    }

    // MARK: - Setup

    private func setupUI() {
        view.backgroundColor = .systemBackground

        contentContainer.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(contentContainer)
        NSLayoutConstraint.activate([
            contentContainer.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            contentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            contentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            contentContainer.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }

    private func setupNavigationItems() {
        lastNavigationSourceTitle = viewModel.displaySourceTitle(languageCode: appSettings.languageCode)
        sourceBarButtonItem.menu = sourceMenu()
        navigationItem.leftBarButtonItem = settingsBarButtonItem
        navigationItem.rightBarButtonItems = [sourceBarButtonItem, refreshBarButtonItem]
        navigationItem.prompt = nil
        updateNavigationTitleView()
    }

    // MARK: - Observation

    private func observeViewModel() {
        withObservationTracking {
            _ = viewModel.state
            _ = viewModel.source
            _ = appSettings.colorScheme
            _ = appSettings.languageCode
        } onChange: {
            Task { @MainActor [weak self] in
                guard let self else { return }
                self.observationUpdateTask?.cancel()
                self.observationUpdateTask = Task { @MainActor [weak self] in
                    guard let self,
                      !self.isBeingDismissed,
                      !self.isMovingFromParent else { return }
                    self.applyViewModelChanges()
                    self.observeViewModel()
                }
            }
        }
        render()
    }

    private func applyViewModelChanges() {
        let currentLang = appSettings.languageCode
        if lastObservedLanguageCode != currentLang {
            lastObservedLanguageCode = currentLang
            viewModel.loadWeather()
        }
        let sourceTitle = viewModel.displaySourceTitle(languageCode: currentLang)
        if lastNavigationSourceTitle != sourceTitle {
            lastNavigationSourceTitle = sourceTitle
            setupNavigationItems()
        }
        applyAppearance()
        render()
    }

    // MARK: - Render

    private func render() {
        let isLoadingState: Bool
        if case .loading = viewModel.state {
            isLoadingState = true
        } else {
            isLoadingState = false
        }
        coordinator?.setGlobalLoadingVisible(isLoadingState)
        updateHostedView()
    }

    // MARK: - Actions

    @objc
    private func refreshTapped() {
        let now = Date()
        guard now >= nextAllowedRefreshAt else { return }
        nextAllowedRefreshAt = now.addingTimeInterval(2)

        HapticManager.shared.lightImpact()
        coordinator?.setGlobalLoadingVisible(true)

        refreshThrottleTask?.cancel()
        refreshThrottleTask = Task { @MainActor [weak self] in
            defer { self?.refreshThrottleTask = nil }
            try? await Task.sleep(for: .seconds(2))
            guard let self, !Task.isCancelled else { return }
            self.viewModel.loadWeather()
        }
    }

    @objc
    private func settingsTapped() {
        HapticManager.shared.lightImpact()
        coordinator?.showSettings(from: self, appSettings: appSettings)
    }

    private func sourceMenu() -> UIMenu {
        let useLocation = UIAction(
            title: appSettings.string(.sourceCurrentLocation),
            image: UIImage(systemName: "location.fill")
        ) { [weak self] _ in
            HapticManager.shared.selectionChanged()
            self?.viewModel.useCurrentLocation()
        }

        let chooseCity = UIAction(
            title: appSettings.string(.sourceEnterCity),
            image: UIImage(systemName: "magnifyingglass")
        ) { [weak self] _ in
            HapticManager.shared.selectionChanged()
            self?.presentCitySearchSheet(initialQuery: nil)
        }

        let quickCityActions = quickCities.map { city in
            UIAction(title: city) { [weak self] _ in
                HapticManager.shared.selectionChanged()
                self?.viewModel.useCity(city)
            }
        }

        let quickMenu = UIMenu(
            title: appSettings.string(.sourceQuickSelection),
            options: .displayInline,
            children: quickCityActions
        )

        return UIMenu(children: [useLocation, chooseCity, quickMenu])
    }

    private func presentCitySearchSheet(initialQuery: String?) {
        let citySearch = CitySearchView(
            initialQuery: initialQuery,
            onSelect: { [weak self] query in
                self?.dismiss(animated: true) { [weak self] in
                    self?.viewModel.useCity(query)
                }
            },
            onCancel: { [weak self] in
                self?.dismiss(animated: true)
            }
        )
        .environment(\.appSettings, appSettings)

        let hosting = UIHostingController(rootView: citySearch)
        hosting.view.backgroundColor = .clear
        let navigation = UINavigationController(rootViewController: hosting)
        navigation.overrideUserInterfaceStyle = appSettings.colorScheme.uiInterfaceStyle
        navigation.modalPresentationStyle = .pageSheet
        if let sheet = navigation.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.selectedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        present(navigation, animated: true)
    }

    private func updateNavigationTitleView() {
        let titleLabel = UILabel()
        titleLabel.text = appSettings.string(.appTitle)
        titleLabel.font = .systemFont(ofSize: 18, weight: .semibold)
        titleLabel.textColor = .label
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 1
        titleLabel.lineBreakMode = .byTruncatingTail

        let stack = UIStackView(arrangedSubviews: [titleLabel])
        stack.axis = .vertical
        stack.alignment = .center
        stack.spacing = 0
        stack.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
        stack.accessibilityIdentifier = "nav_title_stack"
        titleLabel.accessibilityIdentifier = "nav_app_title_label"
        navigationItem.titleView = stack
    }

    private func applyAppearance() {
        let style = appSettings.colorScheme.uiInterfaceStyle
        overrideUserInterfaceStyle = style
        navigationController?.overrideUserInterfaceStyle = style
    }

    // MARK: - Hosting

    private func updateHostedView() {
        let view = WeatherHostedContent(
            state: viewModel.state,
            lastContent: viewModel.lastSuccessfulData,
            onRetry: { [weak self] in
                HapticManager.shared.lightImpact()
                Task { @MainActor [weak self] in
                    try? await Task.sleep(for: .seconds(0.2))
                    self?.viewModel.loadWeather()
                }
            },
            onAcknowledgeInvalidCity: { [weak self] in
                HapticManager.shared.warning()
                self?.viewModel.acknowledgeInvalidCityWarning()
            },
            appSettings: appSettings
        )

        if let hostingController {
            hostingController.rootView = view
            return
        }

        let hosting = UIHostingController(rootView: view)
        self.hostingController = hosting

        addChild(hosting)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        hosting.view.backgroundColor = .clear
        contentContainer.addSubview(hosting.view)
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: contentContainer.topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: contentContainer.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: contentContainer.trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: contentContainer.bottomAnchor)
        ])
        hosting.didMove(toParent: self)
    }
}
