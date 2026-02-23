    //
    //  GetWeatherUseCase.swift
    //  SkylightWeather
    //

import CoreLocation
import Foundation
import os

@MainActor
final class GetWeatherUseCase {
    
    private let apiClient: WeatherAPIClientProtocol
    private let locationService: LocationService
    private let logger = AppLog.useCase
    
    init(
        apiClient: WeatherAPIClientProtocol,
        locationService: LocationService
    ) {
        self.apiClient = apiClient
        self.locationService = locationService
    }
    
    convenience init() {
        self.init(
            apiClient: WeatherAPIClient(),
            locationService: LocationService()
        )
    }
    
    func execute(source: WeatherRequestSource) async throws -> WeatherViewData {
        logger.debug("Executing weather use case")
        let query = await resolveQuery(for: source)
        let languageCode = L10n.currentLanguageCode()
        
        async let current = apiClient.fetchCurrent(query: query, languageCode: languageCode)
        async let forecast = apiClient.fetchForecast(query: query, days: 7, languageCode: languageCode)
        
        let (currentResult, forecastResult) = try await (current, forecast)
        logger.debug("Received weather payloads, mapping response")
        
        return WeatherMapper.map(current: currentResult, forecast: forecastResult)
    }
    
    private func resolveQuery(for source: WeatherRequestSource) async -> String {
        switch source {
            case .city(let city):
                let trimmed = city.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty {
                    logger.debug("Resolved source query from custom city")
                    return trimmed
                }
                fallthrough
                
            case .currentLocation:
                logger.debug("Resolving source query from geolocation")
                let coord = await locationService.requestLocation()
                return Endpoint.coordinateQuery(lat: coord.latitude, lon: coord.longitude)
        }
    }
}

