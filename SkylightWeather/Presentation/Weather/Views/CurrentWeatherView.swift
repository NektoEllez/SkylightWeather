    //
    //  CurrentWeatherView.swift
    //  SkylightWeather
    //

import SwiftUI

struct CurrentWeatherView: View {
    
    let data: WeatherViewData
    
    var body: some View {
        VStack(spacing: 12) {
            WeatherAnimationView(conditionCode: data.conditionCode, isDay: data.isDay)
                .frame(width: 72, height: 72)
            
            temperatureLabel
            conditionLabel
            feelsLikeLabel
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
        hourly: [],
        daily: []
    )
    return CurrentWeatherView(data: sampleData)
        .padding()
        .background(WeatherGradientColors.colors(for: 1003).first ?? .blue)
}
