import SwiftUI

enum PreviewWeatherData {
    static let gradientBackground = WeatherGradientColors.colors(for: 1003).first ?? .blue

    static let hourly: [HourlyViewData] = [
        .init(id: "0", time: "12:00", temperature: "13°", conditionCode: 1000, isDay: true, isNow: false, precipitationChance: 0, windKph: 5, humidity: 65),
        .init(id: "1", time: "13:00", temperature: "14°", conditionCode: 1003, isDay: true, isNow: false, precipitationChance: 20, windKph: 8, humidity: 70),
        .init(id: "2", time: "Now", temperature: "15°", conditionCode: 1003, isDay: true, isNow: true, precipitationChance: 30, windKph: 12, humidity: 72),
        .init(id: "3", time: "15:00", temperature: "16°", conditionCode: 1003, isDay: true, isNow: false, precipitationChance: 45, windKph: 8, humidity: 68),
        .init(id: "4", time: "16:00", temperature: "17°", conditionCode: 1000, isDay: true, isNow: false, precipitationChance: 0, windKph: 5, humidity: 55),
        .init(id: "5", time: "17:00", temperature: "16°", conditionCode: 1180, isDay: true, isNow: false, precipitationChance: 80, windKph: 22, humidity: 90),
        .init(id: "6", time: "18:00", temperature: "14°", conditionCode: 1066, isDay: false, isNow: false, precipitationChance: 10, windKph: 3, humidity: 85),
        .init(id: "7", time: "19:00", temperature: "12°", conditionCode: 1066, isDay: false, isNow: false, precipitationChance: 100, windKph: 28, humidity: 95)
    ]

    static let daily: [DailyViewData] = [
        .init(id: "1", weekday: "Today", minTemp: "10°", maxTemp: "18°", conditionCode: 1003, isDay: true, windKph: 14, humidity: 65),
        .init(id: "2", weekday: "Mon", minTemp: "8°", maxTemp: "16°", conditionCode: 1180, isDay: true, windKph: 22, humidity: 80),
        .init(id: "3", weekday: "Tue", minTemp: "5°", maxTemp: "12°", conditionCode: 1066, isDay: true, windKph: 8, humidity: 72)
    ]

    static let sample = WeatherViewData(
        locationName: "Moscow",
        temperature: "15°",
        feelsLike: "Feels like 13°",
        conditionText: "Partly cloudy",
        conditionCode: 1003,
        isDay: true,
        windKph: 14,
        humidity: 68,
        hourly: hourly,
        daily: daily
    )

    static let rain = WeatherViewData(
        locationName: "Saint Petersburg",
        temperature: "8°",
        feelsLike: "Feels like 5°",
        conditionText: "Light rain",
        conditionCode: 1180,
        isDay: true,
        windKph: 32,
        humidity: 88,
        hourly: [],
        daily: []
    )
}
