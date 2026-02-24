    //
    //  WeatherViewData.swift
    //  SkylightWeather
    //

import Foundation

struct WeatherViewData: Equatable, Sendable {
    let locationName: String
    let temperature: String
    let feelsLike: String
    let conditionText: String
    let conditionCode: Int
    let isDay: Bool
    /// Current wind speed in km/h
    let windKph: Double?
    /// Current relative humidity 0–100
    let humidity: Int?
    let hourly: [HourlyViewData]
    let daily: [DailyViewData]
}
