    //
    //  WeatherAPIClient.swift
    //  SkylightWeather
    //

import Foundation
import os

enum APIError: LocalizedError {
    case invalidURL
    case cityNotFound
    case network(URLError)
    case server(Int)
    case decoding(Error)
    case unknown
    
    var errorDescription: String? {
        switch self {
            case .invalidURL:
                return L10n.text(.errorInvalidURL)
            case .cityNotFound:
                return L10n.text(.errorCityNotFound)
            case .network:
                return L10n.text(.errorNoInternet)
            case .server(let code):
                return L10n.format(.errorServerFormat, languageCode: nil, code)
            case .decoding:
                return L10n.text(.errorDecoding)
            case .unknown:
                return L10n.text(.errorUnknown)
        }
    }
}

protocol WeatherAPIClientProtocol: Sendable {
    func fetchCurrent(query: String, languageCode: String) async throws -> CurrentWeatherDTO
    func fetchForecast(query: String, days: Int, languageCode: String) async throws -> ForecastDTO
}

    /// Network client for WeatherAPI.com.
    /// All methods are `nonisolated` — fetch + JSON decoding run on the cooperative
    /// thread pool, keeping MainActor free for UI work.
final class WeatherAPIClient: WeatherAPIClientProtocol, @unchecked Sendable {
    
    private let session: URLSession
    nonisolated private static let cityNotFoundCodes: Set<Int> = [1003, 1006]
    
    nonisolated init(session: URLSession? = nil) {
        if let session {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.default
            configuration.timeoutIntervalForRequest = 15
            configuration.timeoutIntervalForResource = 30
            configuration.requestCachePolicy = .useProtocolCachePolicy
            configuration.urlCache = URLCache(
                memoryCapacity: 2 * 1024 * 1024,
                diskCapacity: 10 * 1024 * 1024
            )
            self.session = URLSession(configuration: configuration)
        }
    }
    
    nonisolated func fetchCurrent(query: String, languageCode: String) async throws -> CurrentWeatherDTO {
        guard let url = Endpoint.current(query: query, languageCode: languageCode).url else {
            throw APIError.invalidURL
        }
        AppLog.network.debug("Requesting current weather")
        return try await fetch(url: url)
    }
    
    nonisolated func fetchForecast(query: String, days: Int, languageCode: String) async throws -> ForecastDTO {
        guard let url = Endpoint.forecast(query: query, days: days, languageCode: languageCode).url else {
            throw APIError.invalidURL
        }
        AppLog.network.debug("Requesting weather forecast")
        return try await fetch(url: url)
    }
    
        // MARK: - Private
    
    nonisolated private func fetch<T: Decodable>(url: URL) async throws -> T {
        do {
            let (data, response) = try await session.data(from: url)
            try Task.checkCancellation()
            
            guard let http = response as? HTTPURLResponse else {
                throw APIError.unknown
            }
            guard (200...299).contains(http.statusCode) else {
                AppLog.network.error("Weather API server error: \(http.statusCode)")
                if let payload = decodeServerError(from: data),
                   Self.cityNotFoundCodes.contains(payload.code) {
                    AppLog.network.error("Weather API city not found: \(payload.message, privacy: .public)")
                    throw APIError.cityNotFound
                }
                throw APIError.server(http.statusCode)
            }
            
            do {
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                AppLog.network.error("Weather API decoding error: \(error.localizedDescription, privacy: .public)")
                throw APIError.decoding(error)
            }
        } catch is CancellationError {
            throw CancellationError()
        } catch let error as APIError {
            throw error
        } catch let error as URLError {
            AppLog.network.error("Weather API network error: \(error.localizedDescription, privacy: .public)")
            throw APIError.network(error)
        } catch {
            AppLog.network.error("Weather API unknown error: \(error.localizedDescription, privacy: .public)")
            throw APIError.unknown
        }
    }
    
    nonisolated private func decodeServerError(from data: Data) -> APIErrorPayload? {
        do {
            return try JSONDecoder().decode(APIErrorEnvelope.self, from: data).error
        } catch {
            AppLog.network.debug("Server error payload decode failed: \(error.localizedDescription)")
            return nil
        }
    }
}

nonisolated private struct APIErrorEnvelope: Decodable, Sendable {
    let error: APIErrorPayload
}

nonisolated private struct APIErrorPayload: Decodable, Sendable {
    let code: Int
    let message: String
}
