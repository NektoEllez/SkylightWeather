//
//  WeatherViewData.swift
//  SkylightWeather
//

import Foundation

struct WeatherViewData: Sendable {
    let locationName: String
    let temperature: String
    let feelsLike: String
    let conditionText: String
    let conditionCode: Int
    let isDay: Bool
    let hourly: [HourlyViewData]
    let daily: [DailyViewData]
}
