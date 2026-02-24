    //
    //  CurrentWeatherDTO.swift
    //  SkylightWeather
    //

import Foundation

nonisolated struct CurrentWeatherDTO: Decodable, Sendable {
    let location: LocationDTO
    let current: CurrentDTO
    
    nonisolated struct LocationDTO: Decodable, Sendable {
        let name: String
    }
    
    nonisolated struct CurrentDTO: Decodable, Sendable {
        let temp_c: Double
        let feelslike_c: Double
        let is_day: Int
        let condition: ConditionDTO
        let wind_kph: Double?
        let humidity: Int?
    }
    
    nonisolated struct ConditionDTO: Decodable, Sendable {
        let text: String
        let code: Int
    }
}
