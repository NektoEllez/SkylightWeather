//
//  WeatherRequestSource.swift
//  SkylightWeather
//

import Foundation

enum WeatherRequestSource: Equatable, Sendable {
    case currentLocation
    case city(String)

    func displayTitle(languageCode: String) -> String {
        switch self {
        case .currentLocation:
            return L10n.text(.sourceCurrentLocation, languageCode: languageCode)
        case .city(let city):
            return city
        }
    }
}
