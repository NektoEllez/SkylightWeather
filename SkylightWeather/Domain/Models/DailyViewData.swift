    //
    //  DailyViewData.swift
    //  SkylightWeather
    //

import Foundation

struct DailyViewData: Equatable, Identifiable, Sendable {
        /// Stable ID from API date string (e.g. "2024-01-15")
    let id: String
    let weekday: String
    let minTemp: String
    let maxTemp: String
    let conditionCode: Int
        /// Day variant for animation (daily uses day by default)
    let isDay: Bool
        /// Max wind speed for the day in km/h
    let windKph: Double?
        /// Average humidity for the day 0–100
    let humidity: Int?
}
