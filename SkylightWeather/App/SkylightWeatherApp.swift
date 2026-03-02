//
//  SkylightWeatherApp.swift
//  SkylightWeather
//

import SwiftUI
import os

@main
struct SkylightWeatherApp: App {

    @State private var appSettings = AppSettings.shared

    init() {
        #if os(iOS)
        configureNavigationBarAppearance()
        #endif
        AppLog.ui.info("App launched in \(AppRuntimeConfiguration.shared.environment.rawValue, privacy: .public) environment")
    }

    var body: some Scene {
        WindowGroup {
            WeatherView()
                .environment(\.appSettings, appSettings)
                .preferredColorScheme(appSettings.colorScheme)
        }
        #if os(macOS)
        .defaultSize(width: 420, height: 780)
        .windowResizability(.contentMinSize)
        #endif
    }

    #if os(iOS)
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.label]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.label]
        let bar = UINavigationBar.appearance()
        bar.standardAppearance = appearance
        bar.scrollEdgeAppearance = appearance
        bar.compactAppearance = appearance
        bar.compactScrollEdgeAppearance = appearance
        bar.tintColor = .label
    }
    #endif
}
