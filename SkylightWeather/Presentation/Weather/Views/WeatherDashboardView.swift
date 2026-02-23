//
//  WeatherDashboardView.swift
//  SkylightWeather
//

import SwiftUI

struct WeatherDashboardView: View {

    let data: WeatherViewData
    @Environment(\.appSettings) private var settings
    @Environment(\.colorScheme) private var colorScheme
    @State private var selectedCard: Int? = 0

    var body: some View {
        ZStack {
            backgroundGradient
                .ignoresSafeArea()

            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 16) {
                    header
                        .padding(.horizontal, 16)
                    cards
                    PageIndicatorView(count: 3, selectedIndex: $selectedCard)
                        .padding(.horizontal, 16)
                }
                .padding(.vertical, 20)
            }
        }
    }

    private var header: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(data.locationName)
                .font(.system(.largeTitle, design: .rounded, weight: .bold))
                .foregroundStyle(.white)

            Text(data.conditionText)
                .font(.system(.headline, design: .rounded, weight: .medium))
                .foregroundStyle(.white.opacity(0.8))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private var cards: some View {
        if #available(iOS 17.0, *) {
            HorizontalPagingScrollView(
                pageCount: 3,
                selectedIndex: $selectedCard,
                horizontalPadding: 0,
                cardWidthRatio: 0.86,
                pinchScale: 0.93,
                verticalPadding: 24
            ) { index in
                card(at: index)
            }
            .frame(height: 468)
        } else {
            VStack(spacing: 12) {
                card(at: 0)
                    .frame(height: 270)
                card(at: 1)
                    .frame(height: 330)
                card(at: 2)
                    .frame(height: 330)
            }
        }
    }

    private var dailyForecastTitle: String {
        if data.daily.count >= 7 {
            return settings.string(.weeklyForecast)
        }
        return L10n.format(
            .forecastDaysFormat,
            languageCode: settings.languageCode,
            max(data.daily.count, 0)
        )
    }

    @ViewBuilder
    private func card(at index: Int) -> some View {
        switch index {
        case 0:
            weatherCard(title: settings.string(.now)) {
                CurrentWeatherView(data: data)
            }
        case 1:
            weatherCard(title: settings.string(.hourlyForecast)) {
                HourlyForecastView(hours: data.hourly)
            }
        default:
            weatherCard(title: dailyForecastTitle) {
                DailyForecastView(days: data.daily)
            }
        }
    }

    private func weatherCard<Content: View>(title: String, @ViewBuilder content: () -> Content) -> some View {
        VStack(alignment: .leading, spacing: 14) {
            Text(title)
                .font(.system(.headline, design: .rounded, weight: .semibold))
                .foregroundStyle(.white)
                .shadow(color: .black.opacity(0.35), radius: 1, y: 1)

            content()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        }
        .padding(18)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 28, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 28, style: .continuous)
                .strokeBorder(Color.white.opacity(0.28), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.20), radius: 12, y: 6)
    }

    private var cardBackground: some View {
        LinearGradient(
            colors: WeatherGradientColors.colors(for: data.conditionCode),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .overlay(Color.black.opacity(colorScheme == .dark ? 0.24 : 0.14))
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: WeatherGradientColors.colors(for: data.conditionCode),
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

// MARK: - Preview

#Preview {
    let settings = AppSettings.shared
    let sampleData = WeatherViewData(
        locationName: settings.string(.quickCityMoscow),
        temperature: "15°",
        feelsLike: L10n.format(.feelsLikeFormat, languageCode: settings.languageCode, 13),
        conditionText: settings.string(.widgetPlaceholderCondition),
        conditionCode: 1003,
        isDay: true,
        hourly: [
            .init(id: "1", time: settings.string(.now), temperature: "15°", conditionCode: 1003, isDay: true, isNow: true, precipitationChance: 0, windKph: nil),
            .init(id: "2", time: "14:00", temperature: "16°", conditionCode: 1003, isDay: true, isNow: false, precipitationChance: 30, windKph: 12)
        ],
        daily: [
            .init(id: "1", weekday: settings.string(.today), minTemp: "10°", maxTemp: "18°", conditionCode: 1003, isDay: true),
            .init(id: "2", weekday: "Пн", minTemp: "8°", maxTemp: "16°", conditionCode: 1180, isDay: true)
        ]
    )
    WeatherDashboardView(data: sampleData)
        .environment(\.appSettings, AppSettings.shared)
}

#Preview("Rain") {
    let settings = AppSettings.shared
    let rainData = WeatherViewData(
        locationName: settings.string(.quickCitySaintPetersburg),
        temperature: "8°",
        feelsLike: L10n.format(.feelsLikeFormat, languageCode: settings.languageCode, 5),
        conditionText: settings.string(.widgetPlaceholderCondition),
        conditionCode: 1180,
        isDay: true,
        hourly: [],
        daily: []
    )
    return WeatherDashboardView(data: rainData)
        .environment(\.appSettings, AppSettings.shared)
}
