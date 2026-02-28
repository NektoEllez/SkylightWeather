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
        let isProxyEnabled = Self.runtimeConfiguration.weatherProxyBaseURL != nil
        var components = proxyComponents()
        if components == nil {
            components = URLComponents()
            components?.scheme = Self.runtimeConfiguration.weatherAPIScheme
            components?.host = Self.runtimeConfiguration.weatherAPIHost
        }
        guard var components else { return nil }

        switch self {
            case .current(let query, let languageCode):
                components.path = mergedPath(basePath: components.path, endpointPath: "/v1/current.json")
                var queryItems = [
                    URLQueryItem(name: "q", value: query),
                    URLQueryItem(name: "lang", value: languageCode)
                ]
                if !isProxyEnabled {
                    queryItems.insert(URLQueryItem(name: "key", value: Self.runtimeConfiguration.weatherAPIKey), at: 0)
                }
                components.queryItems = queryItems
                
            case .forecast(let query, let days, let languageCode):
                components.path = mergedPath(basePath: components.path, endpointPath: "/v1/forecast.json")
                var queryItems = [
                    URLQueryItem(name: "q", value: query),
                    URLQueryItem(name: "days", value: "\(days)"),
                    URLQueryItem(name: "lang", value: languageCode)
                ]
                if !isProxyEnabled {
                    queryItems.insert(URLQueryItem(name: "key", value: Self.runtimeConfiguration.weatherAPIKey), at: 0)
                }
                components.queryItems = queryItems
        }
        return components.url
    }

    nonisolated private func proxyComponents() -> URLComponents? {
        guard let proxyBaseURL = Self.runtimeConfiguration.weatherProxyBaseURL else { return nil }
        return URLComponents(string: proxyBaseURL)
    }

    nonisolated private func mergedPath(basePath: String, endpointPath: String) -> String {
        let normalizedBase = basePath.hasSuffix("/") ? String(basePath.dropLast()) : basePath
        if normalizedBase.isEmpty || normalizedBase == "/" {
            return endpointPath
        }
        return normalizedBase + endpointPath
    }
}
