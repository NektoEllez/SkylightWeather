    //
    //  WeatherMapper.swift
    //  SkylightWeather
    //

import Foundation
import os

struct WeatherMapper {
    private static let logger = AppLog.mapper
    private static let placeholder = "\u{2014}"
    
    private static let parseDateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter
    }()
    
    private static let weekdayDisplayFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return formatter
    }()
    
    static func map(current: CurrentWeatherDTO, forecast: ForecastDTO) -> WeatherViewData {
        let days = forecast.forecast.forecastday
        let languageCode = L10n.currentLanguageCode()
        
        return WeatherViewData(
            locationName: current.location.name,
            temperature: "\(Int(current.current.temp_c))\u{00B0}",
            feelsLike: L10n.format(
                .feelsLikeFormat,
                languageCode: languageCode,
                Int(current.current.feelslike_c)
            ),
            conditionText: current.current.condition.text,
            conditionCode: current.current.condition.code,
            isDay: current.current.is_day == 1,
            windKph: current.current.wind_kph,
            humidity: current.current.humidity,
            hourly: buildHourly(days: days, location: current.location, languageCode: languageCode),
            daily: buildDaily(days: days, languageCode: languageCode)
        )
    }
    
        // MARK: - Hourly
    
    private static func buildHourly(
        days: [ForecastDTO.ForecastDayDTO],
        location: CurrentWeatherDTO.LocationDTO,
        languageCode: String
    ) -> [HourlyViewData] {
        guard days.count >= 2 else { return [] }
        
        let currentHour = locationCurrentHour(location: location)
        
        let todayHours = days[0].hour.filter { hourDTO in
            guard let hour = extractHour(from: hourDTO.time) else {
                logger.error("Skipping invalid hourly time format: \(hourDTO.time, privacy: .public)")
                return false
            }
            return hour >= currentHour
        }
        
        let tomorrowHours = days[1].hour
        
        return (todayHours + tomorrowHours).enumerated().map { index, dto in
            let precipChance = max(dto.chance_of_rain ?? 0, dto.chance_of_snow ?? 0)
            return HourlyViewData(
                id: dto.time,
                time: formatHourTime(dto.time, isFirst: index == 0, languageCode: languageCode),
                temperature: "\(Int(dto.temp_c))\u{00B0}",
                conditionCode: dto.condition.code,
                isDay: dto.is_day == 1,
                isNow: index == 0,
                precipitationChance: precipChance,
                windKph: dto.wind_kph,
                humidity: dto.humidity
            )
        }
    }
    
        // MARK: - Daily
    
    private static func buildDaily(
        days: [ForecastDTO.ForecastDayDTO],
        languageCode: String
    ) -> [DailyViewData] {
        Array(days.prefix(7)).map { day in
            DailyViewData(
                id: day.date,
                weekday: formatWeekday(day.date, languageCode: languageCode),
                minTemp: "\(Int(day.day.mintemp_c))\u{00B0}",
                maxTemp: "\(Int(day.day.maxtemp_c))\u{00B0}",
                conditionCode: day.day.condition.code,
                isDay: true,
                windKph: day.day.maxwind_kph,
                humidity: day.day.avghumidity
            )
        }
    }
    
        // MARK: - Helpers
    
    /// Current hour in the location's timezone. Falls back to device time if tz_id/localtime_epoch unavailable.
    private static func locationCurrentHour(location: CurrentWeatherDTO.LocationDTO) -> Int {
        guard let tzId = location.tz_id,
              let epoch = location.localtime_epoch,
              let tz = TimeZone(identifier: tzId) else {
            return Calendar.current.component(.hour, from: Date())
        }
        var cal = Calendar.current
        cal.timeZone = tz
        return cal.component(.hour, from: Date(timeIntervalSince1970: TimeInterval(epoch)))
    }
    
    private static func extractHour(from timeString: String) -> Int? {
        guard let timePart = extractTimePart(from: timeString) else {
            return nil
        }
        let components = timePart.split(separator: ":")
        guard let hourToken = components.first, let hour = Int(hourToken), (0...23).contains(hour) else {
            logger.error("Invalid hour value in forecast time: \(timeString, privacy: .public)")
            return nil
        }
        return hour
    }
    
    private static func formatHourTime(
        _ timeString: String,
        isFirst: Bool,
        languageCode: String
    ) -> String {
        if isFirst {
            return L10n.text(.now, languageCode: languageCode)
        }
        guard let timePart = extractTimePart(from: timeString) else {
            logger.error("Invalid hour time format in forecast: \(timeString, privacy: .public)")
            return placeholder
        }
        return timePart
    }
    
    private static func formatWeekday(_ dateString: String, languageCode: String) -> String {
        guard let date = parseDateFormatter.date(from: dateString) else {
            logger.error("Invalid date format in forecast: \(dateString, privacy: .public)")
            return placeholder
        }
        
        if Calendar.current.isDateInToday(date) {
            return L10n.text(.today, languageCode: languageCode)
        }
        
        weekdayDisplayFormatter.locale = L10n.locale(for: languageCode)
        return weekdayDisplayFormatter.string(from: date).capitalized
    }

    private static func extractTimePart(from timeString: String) -> String? {
        let parts = timeString.split(separator: " ")
        guard parts.count == 2 else { return nil }
        let timePart = String(parts[1])
        return timePart.contains(":") ? timePart : nil
    }
}
