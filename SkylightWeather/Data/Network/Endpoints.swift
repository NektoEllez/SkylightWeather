//
//  Endpoints.swift
//  SkylightWeather
//

import Foundation

enum Endpoint {
    nonisolated private static let runtimeConfiguration = AppRuntimeConfiguration.shared

    case current(query: String, languageCode: String)
    case forecast(query: String, days: Int, languageCode: String)

    nonisolated static func coordinateQuery(lat: Double, lon: Double) -> String {
        "\(lat),\(lon)"
    }

    nonisolated var url: URL? {
        var components = URLComponents()
        components.scheme = Self.runtimeConfiguration.weatherAPIScheme
        components.host = Self.runtimeConfiguration.weatherAPIHost

        switch self {
        case .current(let query, let languageCode):
            components.path = "/v1/current.json"
            components.queryItems = [
                URLQueryItem(name: "key", value: Self.runtimeConfiguration.weatherAPIKey),
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "lang", value: languageCode)
            ]

        case .forecast(let query, let days, let languageCode):
            components.path = "/v1/forecast.json"
            components.queryItems = [
                URLQueryItem(name: "key", value: Self.runtimeConfiguration.weatherAPIKey),
                URLQueryItem(name: "q", value: query),
                URLQueryItem(name: "days", value: "\(days)"),
                URLQueryItem(name: "lang", value: languageCode)
            ]
        }
        return components.url
    }
}
