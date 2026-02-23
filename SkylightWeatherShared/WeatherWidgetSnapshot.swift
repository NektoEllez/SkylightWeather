    //
    //  WeatherWidgetSnapshot.swift
    //  SkylightWeatherShared
    //

import Foundation

public struct WeatherWidgetSnapshot: Codable {
    public let locationName: String
    public let temperature: String
    public let conditionText: String
    public let conditionCode: Int
    public let updatedAt: Date
    
    public init(
        locationName: String,
        temperature: String,
        conditionText: String,
        conditionCode: Int,
        updatedAt: Date
    ) {
        self.locationName = locationName
        self.temperature = temperature
        self.conditionText = conditionText
        self.conditionCode = conditionCode
        self.updatedAt = updatedAt
    }
    
}
