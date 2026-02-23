//
//  WeatherViewController.swift
//  SkylightWeather
//

import UIKit
import SwiftUI
import Observation


final class WeatherViewController: UIViewController {

    weak var coordinator: (any WeatherViewControllerCoordinating)?

    private let viewModel = WeatherViewModel()
    private let appSettings = AppSettings.shared

    private let contentContainer = UIView()
    private let loadingView = UIActivityIndicatorView(style: .large)
    private var hostingController: UIHostingController<WeatherHostedContent>?
    private var lastObservedLanguageCode: String?

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

        loadingView.translatesAutoresizingMaskIntoConstraints = false
        loadingView.hidesWhenStopped = true
        view.addSubview(loadingView)
        NSLayoutConstraint.activate([
            loadingView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loadingView.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }

    private func setupNavigationItems() {
        title = appSettings.string(.appTitle)

        let refreshItem = UIBarButtonItem(
            image: UIImage(systemName: "arrow.clockwise"),
            style: .plain,
            target: self,
            action: #selector(refreshTapped)
        )

        let sourceItem = UIBarButtonItem(
            image: UIImage(systemName: "location.magnifyingglass"),
            menu: sourceMenu()
        )

        let settingsItem = UIBarButtonItem(
            image: UIImage(systemName: "gearshape"),
            style: .plain,
            target: self,
            action: #selector(settingsTapped)
        )

        navigationItem.leftBarButtonItem = settingsItem
        navigationItem.rightBarButtonItems = [sourceItem, refreshItem]
        updateSourcePrompt()
    }

    // MARK: - Observation

    private func observeViewModel() {
        withObservationTracking {
            _ = self.viewModel.state
            _ = self.viewModel.source
            _ = self.appSettings.colorScheme
            _ = self.appSettings.languageCode
        } onChange: { [weak self] in
            guard let self else { return }
            Task { @MainActor [weak self] in
                guard let self else { return }
                let currentLang = self.appSettings.languageCode
                if self.lastObservedLanguageCode != currentLang {
                    self.lastObservedLanguageCode = currentLang
                    self.viewModel.loadWeather()
                }
                self.applyAppearance()
                self.render()
                self.setupNavigationItems()
                self.observeViewModel()
            }
        }
        render()
    }

    // MARK: - Render

    private func render() {
        switch viewModel.state {
        case .loading:
            loadingView.startAnimating()
        case .content, .error, .cityNotFound:
            loadingView.stopAnimating()
        }
        updateHostedView()
    }

    // MARK: - Actions

    @objc
    private func refreshTapped() {
        HapticManager.shared.lightImpact()
        viewModel.loadWeather()
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
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(navigation, animated: true)
    }

    private func updateSourcePrompt() {
        navigationItem.prompt = L10n.format(
            .sourcePrefixFormat,
            languageCode: appSettings.languageCode,
            viewModel.displaySourceTitle(languageCode: appSettings.languageCode)
        )
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
            onRetry: { [weak self] in
                HapticManager.shared.lightImpact()
                self?.viewModel.loadWeather()
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
