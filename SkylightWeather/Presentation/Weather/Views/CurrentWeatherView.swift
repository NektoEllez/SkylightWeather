    //
    //  CurrentWeatherView.swift
    //  SkylightWeather
    //

import SwiftUI

struct CurrentWeatherView: View {

    let data: WeatherViewData
    @Environment(\.appSettings) private var settings

    var body: some View {
        VStack(spacing: 12) {
            WeatherAnimationView(conditionCode: data.conditionCode, isDay: data.isDay)
                .frame(width: 72, height: 72)

            temperatureLabel
            conditionLabel
            feelsLikeLabel
            weatherStatsRow
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .multilineTextAlignment(.center)
    }

    // MARK: - Subviews

    private var temperatureLabel: some View {
        Text(data.temperature)
            .font(.system(size: 72, weight: .thin, design: .rounded))
            .foregroundStyle(.white)
    }

    private var conditionLabel: some View {
        Text(data.conditionText)
            .font(.system(.title3, design: .rounded, weight: .semibold))
            .foregroundStyle(.white.opacity(0.95))
    }

    private var feelsLikeLabel: some View {
        Text(data.feelsLike)
            .font(.system(.subheadline, design: .rounded, weight: .medium))
            .foregroundStyle(.white.opacity(0.78))
    }

    @ViewBuilder
    private var weatherStatsRow: some View {
        let windPart: String? = data.windKph.map {
            "\(Int($0)) \(settings.string(.windUnit))"
        }
        let humPart: String? = data.humidity.map { "\($0)%" }

        if windPart != nil || humPart != nil {
            HStack(spacing: 20) {
                if let wind = windPart {
                    Label(wind, systemImage: "wind")
                }
                if let hum = humPart {
                    Label(hum, systemImage: "humidity.fill")
                }
            }
            .font(.system(.subheadline, design: .rounded))
            .foregroundStyle(.white.opacity(0.72))
            .padding(.top, 2)
        }
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
        windKph: 14,
        humidity: 68,
        hourly: [],
        daily: []
    )
    return CurrentWeatherView(data: sampleData)
        .padding()
        .background(WeatherGradientColors.colors(for: 1003).first ?? .blue)
        .environment(\.appSettings, AppSettings.shared)
}
