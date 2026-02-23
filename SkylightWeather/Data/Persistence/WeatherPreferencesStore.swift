    //
    //  WeatherPreferencesStore.swift
    //  SkylightWeather
    //

import Foundation
import os

@MainActor
final class WeatherPreferencesStore {
    
    private let defaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    private let logger = AppLog.preferences
    
    init(defaults optionalDefaults: UserDefaults? = nil) {
        self.defaults = optionalDefaults ?? UserDefaults(suiteName: SharedStorageKeys.appGroup) ?? .standard
    }
    
    func loadSelectedCity() -> String? {
        let city = defaults.string(forKey: SharedStorageKeys.selectedCity)
        logger.debug("Loaded selected city from preferences")
        return city
    }
    
    func saveSelectedCity(_ city: String?) {
        guard let city, !city.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            defaults.removeObject(forKey: SharedStorageKeys.selectedCity)
            logger.info("Cleared selected city in preferences")
            return
        }
        defaults.set(city, forKey: SharedStorageKeys.selectedCity)
        logger.info("Saved selected city in preferences")
    }
    
    func saveWidgetSnapshot(from weather: WeatherViewData) {
        let snapshot = WeatherWidgetSnapshot(
            locationName: weather.locationName,
            temperature: weather.temperature,
            conditionText: weather.conditionText,
            conditionCode: weather.conditionCode,
            updatedAt: Date()
        )
        
        do {
            let data = try encoder.encode(snapshot)
            defaults.set(data, forKey: SharedStorageKeys.widgetSnapshot)
        } catch {
            logger.error("Failed to encode widget snapshot: \(error.localizedDescription)")
        }
    }
    
    func loadWidgetSnapshot() -> WeatherWidgetSnapshot? {
        guard let data = defaults.data(forKey: SharedStorageKeys.widgetSnapshot) else {
            return nil
        }
        do {
            return try decoder.decode(WeatherWidgetSnapshot.self, from: data)
        } catch {
            logger.error("Failed to decode widget snapshot: \(error.localizedDescription)")
            return nil
        }
    }
}
