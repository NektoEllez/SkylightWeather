    //
    //  HourlyViewData.swift
    //  SkylightWeather
    //

import Foundation

struct HourlyViewData: Identifiable, Sendable {
        /// Stable ID from API time string (e.g. "2024-01-15 14:00")
    let id: String
    let time: String
    let temperature: String
    let conditionCode: Int
    let isDay: Bool
    let isNow: Bool
        /// Precipitation chance 0–100 (rain or snow, whichever is higher)
    let precipitationChance: Int
        /// Wind speed in km/h
    let windKph: Double?
}
