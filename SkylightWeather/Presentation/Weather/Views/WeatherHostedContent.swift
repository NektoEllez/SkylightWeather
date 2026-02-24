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
    let settings = AppSettings.shared
    let sampleData = WeatherViewData(
        locationName: settings.string(.quickCityMoscow),
        temperature: "15°",
        feelsLike: L10n.format(.feelsLikeFormat, languageCode: settings.languageCode, 13),
        conditionText: settings.string(.widgetPlaceholderCondition),
        conditionCode: 1003,
        isDay: true,
        windKph: 14,
        humidity: 68,
        hourly: [],
        daily: []
    )
    return WeatherHostedContent(
        state: .content(sampleData),
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
