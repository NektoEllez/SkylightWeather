    //
    //  WeatherMapper.swift
    //  SkylightWeather
    //

import Foundation

struct WeatherMapper {
    
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
            hourly: buildHourly(days: days, languageCode: languageCode),
            daily: buildDaily(days: days, languageCode: languageCode)
        )
    }
    
        // MARK: - Hourly
    
    private static func buildHourly(
        days: [ForecastDTO.ForecastDayDTO],
        languageCode: String
    ) -> [HourlyViewData] {
        guard days.count >= 2 else { return [] }
        
        let currentHour = Calendar.current.component(.hour, from: Date())
        
        let todayHours = days[0].hour.filter { hourDTO in
            let hour = extractHour(from: hourDTO.time)
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
                windKph: dto.wind_kph
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
                isDay: true
            )
        }
    }
    
        // MARK: - Helpers
    
    private static func extractHour(from timeString: String) -> Int {
        let parts = timeString.split(separator: " ")
        guard parts.count == 2 else { return 0 }
        let timePart = parts[1].split(separator: ":")
        return Int(timePart[0]) ?? 0
    }
    
    private static func formatHourTime(
        _ timeString: String,
        isFirst: Bool,
        languageCode: String
    ) -> String {
        if isFirst {
            return L10n.text(.now, languageCode: languageCode)
        }
        let parts = timeString.split(separator: " ")
        guard parts.count == 2 else { return "" }
        return String(parts[1])
    }
    
    private static func formatWeekday(_ dateString: String, languageCode: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        guard let date = formatter.date(from: dateString) else { return "" }
        
        if Calendar.current.isDateInToday(date) {
            return L10n.text(.today, languageCode: languageCode)
        }
        
        let weekdayFormatter = DateFormatter()
        weekdayFormatter.locale = L10n.locale(for: languageCode)
        weekdayFormatter.dateFormat = "EEE"
        return weekdayFormatter.string(from: date).capitalized
    }
}
