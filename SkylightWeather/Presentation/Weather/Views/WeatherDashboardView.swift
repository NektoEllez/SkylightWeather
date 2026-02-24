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
    @State private var isHourlyScrollInteracting = false

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
            .accessibilityIdentifier("weather_vertical_scroll")
        }
        .accessibilityIdentifier("weather_dashboard")
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
        HorizontalPagingScrollView(
            pageCount: 3,
            selectedIndex: $selectedCard,
            scrollEnabled: !isHourlyScrollInteracting,
            horizontalPadding: 0,
            cardWidthRatio: 0.86,
            pinchScale: 0.93,
            verticalPadding: 24
        ) { index in
            card(at: index)
        }
        .accessibilityIdentifier("weather_cards_pager")
        .frame(height: 468)
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
            .accessibilityIdentifier("weather_card_now")
        case 1:
            weatherCard(title: settings.string(.hourlyForecast)) {
                HourlyForecastView(
                    hours: data.hourly,
                    onInteractionChanged: { isInteracting in
                        isHourlyScrollInteracting = isInteracting
                    }
                )
            }
            .accessibilityIdentifier("weather_card_hourly")
        default:
            weatherCard(title: dailyForecastTitle) {
                DailyForecastView(days: data.daily)
            }
            .accessibilityIdentifier("weather_card_daily")
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
    WeatherDashboardView(data: PreviewWeatherData.sample)
        .environment(\.appSettings, AppSettings.shared)
}

#Preview("Rain") {
    WeatherDashboardView(data: PreviewWeatherData.rain)
        .environment(\.appSettings, AppSettings.shared)
}
