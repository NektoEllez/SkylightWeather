    //
    //  AppRuntimeConfiguration.swift
    //  SkylightWeather
    //

import Foundation
import os

enum AppEnvironment: String, Sendable {
    case dev
    case prod
    
    nonisolated init(rawValueOrFallback value: String?) {
        switch value?.lowercased() {
            case Self.prod.rawValue:
                self = .prod
            default:
                self = .dev
        }
    }
}

struct AppRuntimeConfiguration: Sendable {
    let environment: AppEnvironment
    let weatherAPIScheme: String
    let weatherAPIHost: String
    /// Optional backend proxy base URL (for example: https://weather-proxy.example.com).
    /// When present, the app sends weather requests to proxy and does not attach provider API key.
    let weatherProxyBaseURL: String?
    // SECURITY NOTE:
    // Client-side API keys are not truly secret, even when obfuscated.
    // For production security, keep provider credentials encrypted and managed on backend,
    // and have the app call your backend/proxy instead of the third-party API directly.
    let weatherAPIKey: String
    
    nonisolated static let shared = load()
    
    nonisolated private static func load(bundle: Bundle = .main) -> AppRuntimeConfiguration {
        let environment = AppEnvironment(rawValueOrFallback: bundle.string(forInfoDictionaryKey: InfoKey.environment))
        
        let scheme = bundle.string(forInfoDictionaryKey: InfoKey.weatherAPIScheme)?.trimmed
        let host = bundle.string(forInfoDictionaryKey: InfoKey.weatherAPIHost)?.trimmed
        let key = bundle.string(forInfoDictionaryKey: InfoKey.weatherAPIKey)?.trimmed
        let proxyBaseURL = bundle.string(forInfoDictionaryKey: InfoKey.weatherProxyBaseURL)?.trimmed
        
        let resolvedScheme = scheme?.isEmpty == false ? (scheme ?? Defaults.weatherAPIScheme) : Defaults.weatherAPIScheme
        let resolvedHost = host?.isEmpty == false ? (host ?? Defaults.weatherAPIHost) : Defaults.weatherAPIHost
        let resolvedKey = key?.isEmpty == false ? (key ?? Defaults.weatherAPIKey) : Defaults.weatherAPIKey
        let resolvedProxyBaseURL = proxyBaseURL?.isEmpty == false ? proxyBaseURL : nil
        
        if resolvedScheme == Defaults.weatherAPIScheme,
           resolvedHost == Defaults.weatherAPIHost,
           resolvedKey == Defaults.weatherAPIKey {
            AppLog.network.notice("Runtime config uses fallback values")
        }
        if resolvedProxyBaseURL != nil {
            AppLog.network.notice("Runtime config uses WEATHER_PROXY_BASE_URL; provider API key is bypassed on client")
        } else if resolvedKey.isEmpty {
            AppLog.network.error("WEATHER_API_KEY is empty for current environment")
        }
        
        return AppRuntimeConfiguration(
            environment: environment,
            weatherAPIScheme: resolvedScheme,
            weatherAPIHost: resolvedHost,
            weatherProxyBaseURL: resolvedProxyBaseURL,
            weatherAPIKey: resolvedKey
        )
    }
}

private enum InfoKey {
    nonisolated static let environment = "APP_ENVIRONMENT"
    nonisolated static let weatherAPIScheme = "WEATHER_API_SCHEME"
    nonisolated static let weatherAPIHost = "WEATHER_API_HOST"
    nonisolated static let weatherAPIKey = "WEATHER_API_KEY"
    nonisolated static let weatherProxyBaseURL = "WEATHER_PROXY_BASE_URL"
}

private enum Defaults {
    nonisolated static let weatherAPIScheme = "https"
    nonisolated static let weatherAPIHost = "api.weatherapi.com"
    nonisolated static let weatherAPIKey = ""
}

private extension Bundle {
    nonisolated func string(forInfoDictionaryKey key: String) -> String? {
        object(forInfoDictionaryKey: key) as? String
    }
}
