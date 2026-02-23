//
//  DailyViewData.swift
//  SkylightWeather
//

import Foundation

struct DailyViewData: Identifiable, Sendable {
    /// Stable ID from API date string (e.g. "2024-01-15")
    let id: String
    let weekday: String
    let minTemp: String
    let maxTemp: String
    let conditionCode: Int
    /// Day variant for animation (daily uses day by default)
    let isDay: Bool
}
