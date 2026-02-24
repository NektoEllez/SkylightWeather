    //
    //  WeatherViewModel.swift
    //  SkylightWeather
    //

import Foundation
import Observation
import os
#if canImport(WidgetKit)
import WidgetKit
#endif

enum ViewState: Sendable {
    case loading
    case content(WeatherViewData)
    case error(String)
    case cityNotFound(String)
}

@MainActor
@Observable
final class WeatherViewModel {
    
    var state: ViewState = .loading
    var source: WeatherRequestSource
    var lastUpdatedAt: Date?
    private(set) var lastSuccessfulData: WeatherViewData?
    
    private let useCase: GetWeatherUseCase
    private let preferencesStore: WeatherPreferencesStore
    private let logger = AppLog.viewModel
    private var loadTask: Task<Void, Never>?
    private var rollbackSourceAfterInvalidCity: WeatherRequestSource?
    
    init(useCase: GetWeatherUseCase, preferencesStore: WeatherPreferencesStore) {
        self.useCase = useCase
        self.preferencesStore = preferencesStore
        if let savedCity = preferencesStore.loadSelectedCity() {
            self.source = .city(savedCity)
        } else {
            self.source = .currentLocation
        }
    }
    
    convenience init() {
        self.init(
            useCase: GetWeatherUseCase(),
            preferencesStore: WeatherPreferencesStore()
        )
    }
    
    func loadWeather() {
        load(source: source)
    }
    
    func useCurrentLocation() {
        logger.info("Using current location as weather source")
        rollbackSourceAfterInvalidCity = nil
        source = .currentLocation
        preferencesStore.saveSelectedCity(nil)
        load(source: source)
    }
    
    func useCity(_ city: String) {
        guard let trimmed = city.trimmedOrNil else { return }
        logger.info("Using custom city as weather source")
        rollbackSourceAfterInvalidCity = source
        source = .city(trimmed)
        load(source: source)
    }
    
    func displaySourceTitle(languageCode: String) -> String {
        source.displayTitle(languageCode: languageCode)
    }
    
    private func load(source: WeatherRequestSource) {
        logger.debug("Starting weather load")
        loadTask?.cancel()
        state = .loading
        
        loadTask = Task { [weak self] in
            guard let self else { return }
            do {
                let data = try await self.useCase.execute(source: source)
                guard !Task.isCancelled else { return }
                self.logger.info("Weather load succeeded")
                self.lastSuccessfulData = data
                self.state = .content(data)
                self.persist(source: source)
                self.rollbackSourceAfterInvalidCity = nil
                self.lastUpdatedAt = Date()
                self.preferencesStore.saveWidgetSnapshot(from: data)
#if canImport(WidgetKit)
                WidgetCenter.shared.reloadAllTimelines()
#endif
            } catch is CancellationError {
                self.logger.debug("Weather load cancelled")
                return
            } catch {
                guard !Task.isCancelled else { return }
                self.logger.error("Weather load failed: \(error.localizedDescription, privacy: .public)")
                if case APIError.cityNotFound = error,
                   case .city = source {
                    self.state = .cityNotFound(L10n.text(.invalidCityWarning))
                } else {
                    self.state = .error(error.localizedDescription)
                }
            }
        }
    }
    
    func acknowledgeInvalidCityWarning() {
        guard case .cityNotFound = state else { return }
        let fallbackSource = rollbackSourceAfterInvalidCity ?? .currentLocation
        logger.info("Invalid city warning acknowledged, restoring previous source")
        rollbackSourceAfterInvalidCity = nil
        source = fallbackSource
        load(source: fallbackSource)
    }
    
    func cancelLoading() {
        logger.debug("Cancelling in-flight weather load")
        loadTask?.cancel()
        loadTask = nil
    }
    
    private func persist(source: WeatherRequestSource) {
        switch source {
            case .currentLocation:
                preferencesStore.saveSelectedCity(nil)
            case .city(let city):
                preferencesStore.saveSelectedCity(city)
        }
    }
}
