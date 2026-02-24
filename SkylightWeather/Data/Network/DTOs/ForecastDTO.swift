    //
    //  ForecastDTO.swift
    //  SkylightWeather
    //

import Foundation

nonisolated struct ForecastDTO: Decodable, Sendable {
    let forecast: ForecastDaysDTO
    
    nonisolated struct ForecastDaysDTO: Decodable, Sendable {
        let forecastday: [ForecastDayDTO]
    }
    
    nonisolated struct ForecastDayDTO: Decodable, Sendable {
        let date: String
        let day: DayDTO
        let hour: [HourDTO]
    }
    
    nonisolated struct DayDTO: Decodable, Sendable {
        let mintemp_c: Double
        let maxtemp_c: Double
        let condition: CurrentWeatherDTO.ConditionDTO
        let maxwind_kph: Double?
        let avghumidity: Int?
    }
    
    nonisolated struct HourDTO: Decodable, Sendable {
        let time: String
        let temp_c: Double
        let is_day: Int
        let condition: CurrentWeatherDTO.ConditionDTO
        let chance_of_rain: Int?
        let chance_of_snow: Int?
        let wind_kph: Double?
        let humidity: Int?
        let precip_mm: Double?
        
        init(
            time: String,
            temp_c: Double,
            is_day: Int,
            condition: CurrentWeatherDTO.ConditionDTO,
            chance_of_rain: Int? = nil,
            chance_of_snow: Int? = nil,
            wind_kph: Double? = nil,
            humidity: Int? = nil,
            precip_mm: Double? = nil
        ) {
            self.time = time
            self.temp_c = temp_c
            self.is_day = is_day
            self.condition = condition
            self.chance_of_rain = chance_of_rain
            self.chance_of_snow = chance_of_snow
            self.wind_kph = wind_kph
            self.humidity = humidity
            self.precip_mm = precip_mm
        }
        
        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            time = try c.decode(String.self, forKey: .time)
            temp_c = try c.decode(Double.self, forKey: .temp_c)
            is_day = try c.decode(Int.self, forKey: .is_day)
            condition = try c.decode(CurrentWeatherDTO.ConditionDTO.self, forKey: .condition)
            chance_of_rain = try c.decodeIfPresent(Int.self, forKey: .chance_of_rain)
            chance_of_snow = try c.decodeIfPresent(Int.self, forKey: .chance_of_snow)
            wind_kph = try c.decodeIfPresent(Double.self, forKey: .wind_kph)
            humidity = try c.decodeIfPresent(Int.self, forKey: .humidity)
            precip_mm = try c.decodeIfPresent(Double.self, forKey: .precip_mm)
        }
        
        private enum CodingKeys: String, CodingKey {
            case time, temp_c, is_day, condition
            case chance_of_rain, chance_of_snow, wind_kph, humidity, precip_mm
        }
    }
}
