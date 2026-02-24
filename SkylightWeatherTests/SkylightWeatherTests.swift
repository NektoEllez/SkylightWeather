    //
    //  SkylightWeatherTests.swift
    //  SkylightWeatherTests
    //
    //  Created by Nekto_Ellez on 23.02.2026.
    //

import Foundation
import Testing
@testable import SkylightWeather

@MainActor
struct SkylightWeatherTests {
    
    @Test
    func mapperBuildsHourlyAndDailyFromForecast() async throws {
        let sharedDefaults = UserDefaults(suiteName: SharedStorageKeys.appGroup)
        sharedDefaults?.set("ru", forKey: AppSettings.StorageKey.languageCode)
        defer {
            sharedDefaults?.removeObject(forKey: AppSettings.StorageKey.languageCode)
        }
        
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        
        let today = dateFormatter.string(from: currentDate)
        guard let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate),
              let dayAfterTomorrowDate = Calendar.current.date(byAdding: .day, value: 2, to: currentDate) else {
            Issue.record("Failed to compute date for forecast")
            return
        }
        let tomorrow = dateFormatter.string(from: tomorrowDate)
        let dayAfterTomorrow = dateFormatter.string(from: dayAfterTomorrowDate)
        
        let todayHours = makeHours(for: today)
        let tomorrowHours = makeHours(for: tomorrow)
        
        let forecast = ForecastDTO(
            forecast: .init(
                forecastday: [
                    .init(
                        date: today,
                        day: .init(
                            mintemp_c: 10,
                            maxtemp_c: 20,
                            condition: .init(text: "Sunny", code: 1000),
                            maxwind_kph: 15,
                            avghumidity: 65
                        ),
                        hour: todayHours
                    ),
                    .init(
                        date: tomorrow,
                        day: .init(
                            mintemp_c: 11,
                            maxtemp_c: 21,
                            condition: .init(text: "Cloudy", code: 1003),
                            maxwind_kph: 18,
                            avghumidity: 70
                        ),
                        hour: tomorrowHours
                    ),
                    .init(
                        date: dayAfterTomorrow,
                        day: .init(
                            mintemp_c: 12,
                            maxtemp_c: 22,
                            condition: .init(text: "Rain", code: 1180),
                            maxwind_kph: 21,
                            avghumidity: 75
                        ),
                        hour: makeHours(for: dayAfterTomorrow)
                    )
                ]
            )
        )
        
        let current = CurrentWeatherDTO(
            location: .init(name: "Moscow", localtime_epoch: nil, tz_id: nil),
            current: .init(
                temp_c: 15,
                feelslike_c: 13,
                is_day: 1,
                condition: .init(text: "Sunny", code: 1000),
                wind_kph: 14,
                humidity: 68
            )
        )
        
        let mapped = WeatherMapper.map(current: current, forecast: forecast)
        let currentHour = Calendar.current.component(.hour, from: currentDate)
        let expectedHourlyCount = (24 - currentHour) + 24
        
        #expect(mapped.locationName == "Moscow")
        #expect(mapped.hourly.count == expectedHourlyCount)
        #expect(mapped.hourly.first?.time == L10n.text(.now, languageCode: "ru"))
        #expect(mapped.hourly.first?.isNow == true)
        #expect(mapped.daily.count == 3)
    }
    
    @Test
    func endpointBuildsValidURLs() async throws {
        let query = Endpoint.coordinateQuery(lat: 55.7558, lon: 37.6173)
        let currentURL = Endpoint.current(query: query, languageCode: "ru").url
        let forecastURL = Endpoint.forecast(query: query, days: 3, languageCode: "ru").url
        
        #expect(currentURL != nil)
        #expect(forecastURL != nil)
        
        guard let currentURL, let forecastURL else {
            Issue.record("Endpoint returned nil URL")
            return
        }
        
        let currentComponents = URLComponents(url: currentURL, resolvingAgainstBaseURL: false)
        let forecastComponents = URLComponents(url: forecastURL, resolvingAgainstBaseURL: false)
        
        #expect(currentComponents?.path == "/v1/current.json")
        #expect(forecastComponents?.path == "/v1/forecast.json")
        #expect(forecastComponents?.queryItems?.contains(where: { $0.name == "days" && $0.value == "3" }) == true)
        #expect(currentComponents?.queryItems?.contains(where: { $0.name == "lang" && $0.value == "ru" }) == true)
        #expect(forecastComponents?.queryItems?.contains(where: { $0.name == "lang" && $0.value == "ru" }) == true)
    }

    @Test
    func mapperUsesLocationTimezoneForHourlyFiltering() async throws {
        let sharedDefaults = UserDefaults(suiteName: SharedStorageKeys.appGroup)
        sharedDefaults?.set("en", forKey: AppSettings.StorageKey.languageCode)
        defer {
            sharedDefaults?.removeObject(forKey: AppSettings.StorageKey.languageCode)
        }

        let laTz = TimeZone(identifier: "America/Los_Angeles")!
        var cal = Calendar.current
        cal.timeZone = laTz
        let laNoon = cal.date(from: DateComponents(year: 2025, month: 6, day: 15, hour: 12, minute: 0))!
        let laNoonEpoch = Int(laNoon.timeIntervalSince1970)

        let today = "2025-06-15"
        let tomorrow = "2025-06-16"
        let todayHours = makeHours(for: today)
        let tomorrowHours = makeHours(for: tomorrow)

        let forecast = ForecastDTO(
            forecast: .init(
                forecastday: [
                    .init(
                        date: today,
                        day: .init(
                            mintemp_c: 15,
                            maxtemp_c: 25,
                            condition: .init(text: "Sunny", code: 1000),
                            maxwind_kph: 10,
                            avghumidity: 50
                        ),
                        hour: todayHours
                    ),
                    .init(
                        date: tomorrow,
                        day: .init(
                            mintemp_c: 16,
                            maxtemp_c: 26,
                            condition: .init(text: "Clear", code: 1000),
                            maxwind_kph: 12,
                            avghumidity: 55
                        ),
                        hour: tomorrowHours
                    )
                ]
            )
        )

        let current = CurrentWeatherDTO(
            location: .init(name: "Los Angeles", localtime_epoch: laNoonEpoch, tz_id: "America/Los_Angeles"),
            current: .init(
                temp_c: 22,
                feelslike_c: 21,
                is_day: 1,
                condition: .init(text: "Sunny", code: 1000),
                wind_kph: 8,
                humidity: 45
            )
        )

        let mapped = WeatherMapper.map(current: current, forecast: forecast)
        let expectedCount = (24 - 12) + 24
        #expect(mapped.hourly.count == expectedCount)
        #expect(mapped.hourly.first?.time == L10n.text(.now, languageCode: "en"))
        #expect(mapped.hourly.first?.isNow == true)
        #expect(mapped.hourly[1].time == "13:00")
    }

    @Test
    func mapperUsesFallbackPlaceholderForInvalidDateAndTime() async throws {
        let currentDate = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")

        let today = dateFormatter.string(from: currentDate)
        guard let tomorrowDate = Calendar.current.date(byAdding: .day, value: 1, to: currentDate) else {
            Issue.record("Failed to compute date for forecast")
            return
        }
        let tomorrow = dateFormatter.string(from: tomorrowDate)

        let todayHours = makeHours(for: today)
        var tomorrowHours = makeHours(for: tomorrow)
        tomorrowHours[0] = ForecastDTO.HourDTO(
            time: "bad-time",
            temp_c: 8,
            is_day: 1,
            condition: .init(text: "Cloudy", code: 1003),
            chance_of_rain: 20,
            chance_of_snow: 0,
            wind_kph: 10,
            humidity: 80
        )

        let forecast = ForecastDTO(
            forecast: .init(
                forecastday: [
                    .init(
                        date: today,
                        day: .init(
                            mintemp_c: 8,
                            maxtemp_c: 17,
                            condition: .init(text: "Sunny", code: 1000),
                            maxwind_kph: 15,
                            avghumidity: 60
                        ),
                        hour: todayHours
                    ),
                    .init(
                        date: tomorrow,
                        day: .init(
                            mintemp_c: 7,
                            maxtemp_c: 15,
                            condition: .init(text: "Cloudy", code: 1003),
                            maxwind_kph: 20,
                            avghumidity: 70
                        ),
                        hour: tomorrowHours
                    ),
                    .init(
                        date: "invalid-date",
                        day: .init(
                            mintemp_c: 6,
                            maxtemp_c: 13,
                            condition: .init(text: "Rain", code: 1180),
                            maxwind_kph: 25,
                            avghumidity: 80
                        ),
                        hour: []
                    )
                ]
            )
        )

        let current = CurrentWeatherDTO(
            location: .init(name: "Moscow", localtime_epoch: nil, tz_id: nil),
            current: .init(
                temp_c: 15,
                feelslike_c: 13,
                is_day: 1,
                condition: .init(text: "Sunny", code: 1000),
                wind_kph: 14,
                humidity: 68
            )
        )

        let mapped = WeatherMapper.map(current: current, forecast: forecast)
        #expect(mapped.hourly.contains(where: { $0.time == "—" }))
        #expect(mapped.daily.contains(where: { $0.weekday == "—" }))
    }

    @Test
    func saveSelectedCityTreatsWhitespaceAsNoSelection() async throws {
        let suiteName = "test.SkylightWeather.preferences.\(UUID().uuidString)"
        guard let defaults = UserDefaults(suiteName: suiteName) else {
            Issue.record("Failed to create isolated defaults suite")
            return
        }
        defer {
            defaults.removePersistentDomain(forName: suiteName)
        }

        let store = WeatherPreferencesStore(defaults: defaults)
        store.saveSelectedCity("   ")
        #expect(store.loadSelectedCity() == nil)

        store.saveSelectedCity("  Kazan ")
        #expect(store.loadSelectedCity() == "Kazan")
    }
    
    private func makeHours(for day: String) -> [ForecastDTO.HourDTO] {
        (0...23).map { hour in
            let time = String(format: "%@ %02d:00", day, hour)
            let isDay = (6..<20).contains(hour) ? 1 : 0
            return ForecastDTO.HourDTO(
                time: time,
                temp_c: Double(hour),
                is_day: isDay,
                condition: .init(text: "Clear", code: 1000)
            )
        }
    }
}
