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
    CurrentWeatherView(data: PreviewWeatherData.sample)
        .padding()
        .background(PreviewWeatherData.gradientBackground)
        .environment(\.appSettings, AppSettings.shared)
}
