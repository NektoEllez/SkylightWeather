    //
    //  WeatherHostedContent.swift
    //  SkylightWeather
    //

import SwiftUI

struct WeatherHostedContent: View {
    
    let state: ViewState
    let onRetry: () -> Void
    let onAcknowledgeInvalidCity: () -> Void
    let appSettings: AppSettings
    
    var body: some View {
        Group {
            switch state {
                case .loading:
                    EmptyView()
                case .content(let data):
                    WeatherDashboardView(data: data)
                case .error(let message):
                    ErrorView(
                        message: message,
                        actionTitle: appSettings.string(.retry),
                        iconName: "cloud.slash",
                        onAction: onRetry
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
                case .cityNotFound(let message):
                    ErrorView(
                        message: message,
                        actionTitle: appSettings.string(.ok),
                        iconName: "magnifyingglass.circle",
                        onAction: onAcknowledgeInvalidCity
                    )
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color(.systemBackground))
            }
        }
        .environment(\.appSettings, appSettings)
        .preferredColorScheme(appSettings.colorScheme)
    }
}

    // MARK: - Preview

#Preview("Content") {
    WeatherHostedContent(
        state: .content(PreviewWeatherData.sample),
        onRetry: {},
        onAcknowledgeInvalidCity: {},
        appSettings: AppSettings.shared
    )
}

#Preview("Error") {
    WeatherHostedContent(
        state: .error(AppSettings.shared.string(.errorNoInternet)),
        onRetry: {},
        onAcknowledgeInvalidCity: {},
        appSettings: AppSettings.shared
    )
}
