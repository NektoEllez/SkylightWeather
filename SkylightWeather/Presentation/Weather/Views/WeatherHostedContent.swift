    //
    //  WeatherHostedContent.swift
    //  SkylightWeather
    //

import SwiftUI
#if os(iOS)
import UIKit
private typealias PlatformColor = UIColor
#else
import AppKit
private typealias PlatformColor = NSColor
#endif

struct WeatherHostedContent: View {
    
    let state: ViewState
    let lastContent: WeatherViewData?
    let onRetry: () -> Void
    let onAcknowledgeInvalidCity: () -> Void
    let appSettings: AppSettings
    
    var body: some View {
        Group {
            switch state {
                case .loading:
                    if let lastContent {
                        WeatherDashboardView(data: lastContent)
                    } else {
                        Color(platformBackground)
                            .ignoresSafeArea()
                    }
                case .content(let data):
                    WeatherDashboardView(data: data)
                case .error(let message):
                    ErrorView(
                        message: message,
                        actionTitle: appSettings.string(.retry),
                        iconName: "wifi.exclamationmark",
                        onAction: onRetry
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(platformBackground))
                case .cityNotFound(let message):
                    ErrorView(
                        message: message,
                        actionTitle: appSettings.string(.ok),
                        iconName: "magnifyingglass.circle",
                        onAction: onAcknowledgeInvalidCity
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(platformBackground))
            }
        }
        .environment(\.appSettings, appSettings)
        .preferredColorScheme(appSettings.colorScheme)
    }
}

    private var platformBackground: PlatformColor {
        #if os(iOS)
        .systemBackground
        #else
        .windowBackgroundColor
        #endif
    }

    // MARK: - Preview

#Preview("Content") {
    WeatherHostedContent(
        state: .content(PreviewWeatherData.sample),
        lastContent: nil,
        onRetry: {},
        onAcknowledgeInvalidCity: {},
        appSettings: AppSettings.shared
    )
}

#Preview("Error") {
    WeatherHostedContent(
        state: .error(AppSettings.shared.string(.errorNoInternet)),
        lastContent: PreviewWeatherData.sample,
        onRetry: {},
        onAcknowledgeInvalidCity: {},
        appSettings: AppSettings.shared
    )
}
