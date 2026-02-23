    //
    //  AppCoordinator.swift
    //  SkylightWeather
    //

import SwiftUI
import UIKit
import os

@MainActor
final class AppCoordinator: NSObject {
    
    private let window: UIWindow
    private let navigationController = AdaptiveNavigationController()
    private let logger = AppLog.ui
    private weak var presentedSettingsController: UIViewController?
    
    init(window: UIWindow) {
        self.window = window
    }
    
    func start() {
        let weatherViewController = WeatherViewController()
        weatherViewController.coordinator = self
        
        navigationController.setViewControllers([weatherViewController], animated: false)
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
    
    private func makeSettingsController(appSettings: AppSettings) -> UIViewController {
        let onColorSchemeChange = { [weak self] in
            guard let self else { return }
            self.presentedSettingsController?.overrideUserInterfaceStyle = appSettings.colorScheme.uiInterfaceStyle
        }
        let settingsView = SettingsView(onDone: { [weak self] in
            self?.logger.debug("Closing settings screen")
            self?.presentedSettingsController?.dismiss(animated: true)
        })
            .environment(\.appSettings, appSettings)
            .environment(\.onSheetColorSchemeChange, onColorSchemeChange)
        
        let hosting = UIHostingController(rootView: settingsView)
        hosting.view.backgroundColor = .clear
        let navigation = UINavigationController(rootViewController: hosting)
        navigation.view.backgroundColor = .clear
        navigation.overrideUserInterfaceStyle = appSettings.colorScheme.uiInterfaceStyle
        configureTransparentNavigationBar(navigation.navigationBar)
        navigation.modalPresentationStyle = .pageSheet
        navigation.presentationController?.delegate = self
        if let sheet = navigation.sheetPresentationController {
            sheet.detents = [.medium()]
            sheet.selectedDetentIdentifier = .medium
            sheet.prefersGrabberVisible = true
            sheet.prefersScrollingExpandsWhenScrolledToEdge = false
            sheet.largestUndimmedDetentIdentifier = .medium
        }
        return navigation
    }
    
    private func configureTransparentNavigationBar(_ bar: UINavigationBar) {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        bar.standardAppearance = appearance
        bar.scrollEdgeAppearance = appearance
        bar.compactAppearance = appearance
    }
    
}

extension AppCoordinator: WeatherViewControllerCoordinating {
    func showSettings(from presenter: UIViewController, appSettings: AppSettings) {
        logger.debug("Presenting settings screen")
        let settingsController = makeSettingsController(appSettings: appSettings)
        presentedSettingsController = settingsController
        presenter.present(settingsController, animated: true)
    }
}

extension AppCoordinator: UIAdaptivePresentationControllerDelegate {
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        logger.debug("Settings screen dismissed interactively")
        presentedSettingsController = nil
    }
}
