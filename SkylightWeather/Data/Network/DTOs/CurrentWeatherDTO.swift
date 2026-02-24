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
        /// Local time in Unix epoch (seconds). Used for hourly "now" in city timezone.
        let localtime_epoch: Int?
        /// Time zone identifier (e.g. "Europe/Moscow"). Used with localtime_epoch for correct hourly filtering.
        let tz_id: String?

        init(name: String, localtime_epoch: Int? = nil, tz_id: String? = nil) {
            self.name = name
            self.localtime_epoch = localtime_epoch
            self.tz_id = tz_id
        }

        init(from decoder: Decoder) throws {
            let c = try decoder.container(keyedBy: CodingKeys.self)
            name = try c.decode(String.self, forKey: .name)
            localtime_epoch = try c.decodeIfPresent(Int.self, forKey: .localtime_epoch)
            tz_id = try c.decodeIfPresent(String.self, forKey: .tz_id)
        }

        private enum CodingKeys: String, CodingKey {
            case name, localtime_epoch, tz_id
        }
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
