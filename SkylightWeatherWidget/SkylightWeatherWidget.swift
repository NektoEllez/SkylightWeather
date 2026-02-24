    //
    //  SkylightWeatherWidget.swift
    //  SkylightWeatherWidget
    //

import SwiftUI
import WidgetKit
import os

private enum WidgetLocalizedKey {
    case placeholderCondition
    case placeholderLocation
    case updatedFormat
    case displayName
    case description
}

private enum WidgetL10n {
    private static let fallbackLanguage = "en"
    private static let supportedLanguages: Set<String> = ["en", "ru"]
    static let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "test.SkylightWeather.widget",
        category: "Widget"
    )
    
    static func currentLanguageCode() -> String {
        let defaults = UserDefaults(suiteName: SharedStorageKeys.appGroup) ?? .standard
        return resolveLanguageCode(defaults.string(forKey: SharedStorageKeys.languageCode))
    }
    
    static func text(_ key: WidgetLocalizedKey, languageCode: String) -> String {
        let localized = translations[key]?[resolveLanguageCode(languageCode)] ?? translations[key]?[fallbackLanguage]
        return localized ?? ""
    }
    
    static func format(_ key: WidgetLocalizedKey, languageCode: String, _ args: CVarArg...) -> String {
        let format = text(key, languageCode: languageCode)
        let locale = Locale(identifier: resolveLanguageCode(languageCode))
        return String(format: format, locale: locale, arguments: args)
    }
    
    private static func resolveLanguageCode(_ languageCode: String?) -> String {
        LanguageCodeResolver.resolve(
            languageCode,
            supported: supportedLanguages,
            fallback: fallbackLanguage
        )
    }
    
    private static let translations: [WidgetLocalizedKey: [String: String]] = [
        .placeholderCondition: [
            "en": "Open the app",
            "ru": "Откройте приложение"
        ],
        .placeholderLocation: [
            "en": "Skylight",
            "ru": "Skylight"
        ],
        .updatedFormat: [
            "en": "Updated %@",
            "ru": "Обновлено %@"
        ],
        .displayName: [
            "en": "Skylight Weather",
            "ru": "Skylight Weather"
        ],
        .description: [
            "en": "Current weather and short status",
            "ru": "Текущая погода и краткий статус"
        ]
    ]
}

private extension WeatherWidgetSnapshot {
    static func placeholder(languageCode: String) -> WeatherWidgetSnapshot {
        WeatherWidgetSnapshot(
            locationName: WidgetL10n.text(.placeholderLocation, languageCode: languageCode),
            temperature: "--°",
            conditionText: WidgetL10n.text(.placeholderCondition, languageCode: languageCode),
            conditionCode: 1003,
            updatedAt: Date()
        )
    }
}

private struct WeatherWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: WeatherWidgetSnapshot
    let languageCode: String
}

private struct WeatherWidgetProvider: TimelineProvider {
    
    func placeholder(in context: Context) -> WeatherWidgetEntry {
        let languageCode = WidgetL10n.currentLanguageCode()
        return WeatherWidgetEntry(
            date: Date(),
            snapshot: .placeholder(languageCode: languageCode),
            languageCode: languageCode
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (WeatherWidgetEntry) -> Void) {
        let languageCode = WidgetL10n.currentLanguageCode()
        completion(
            WeatherWidgetEntry(
                date: Date(),
                snapshot: loadSnapshot(languageCode: languageCode),
                languageCode: languageCode
            )
        )
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<WeatherWidgetEntry>) -> Void) {
        let languageCode = WidgetL10n.currentLanguageCode()
        let entry = WeatherWidgetEntry(
            date: Date(),
            snapshot: loadSnapshot(languageCode: languageCode),
            languageCode: languageCode
        )
        let nextUpdate = Date().addingTimeInterval(30 * 60)
        completion(Timeline(entries: [entry], policy: .after(nextUpdate)))
    }
    
    private func loadSnapshot(languageCode: String) -> WeatherWidgetSnapshot {
        let defaults = UserDefaults(suiteName: SharedStorageKeys.appGroup) ?? .standard
        guard let data = defaults.data(forKey: SharedStorageKeys.widgetSnapshot) else {
            WidgetL10n.logger.debug("Widget snapshot missing, using placeholder")
            return .placeholder(languageCode: languageCode)
        }
        do {
            return try JSONDecoder().decode(WeatherWidgetSnapshot.self, from: data)
        } catch {
            WidgetL10n.logger.error("Widget snapshot decode failed: \(error.localizedDescription, privacy: .public)")
            return .placeholder(languageCode: languageCode)
        }
    }
}

private struct WeatherWidgetEntryView: View {
    let entry: WeatherWidgetProvider.Entry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .firstTextBaseline, spacing: 8) {
                Text(entry.snapshot.locationName)
                    .font(.system(.headline, design: .rounded, weight: .semibold))
                    .lineLimit(1)
                
                Spacer(minLength: 6)
                
                Image(systemName: conditionSymbolName)
                    .font(.system(size: 16, weight: .semibold))
                    .symbolRenderingMode(.hierarchical)
                    .foregroundStyle(.white.opacity(0.95))
            }
            
            Text(entry.snapshot.temperature)
                .font(.system(size: 36, weight: .thin, design: .rounded))
            
            Text(entry.snapshot.conditionText)
                .font(.system(.footnote, design: .rounded, weight: .medium))
                .lineLimit(1)
            
            Spacer(minLength: 0)
            
            Text(updatedAtText)
                .font(.caption2)
                .foregroundStyle(.white.opacity(0.75))
        }
        .padding(14)
        .foregroundStyle(.white)
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: WeatherGradientColors.colors(for: entry.snapshot.conditionCode),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    private var updatedAtText: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: entry.languageCode)
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let time = formatter.string(from: entry.snapshot.updatedAt)
        return WidgetL10n.format(.updatedFormat, languageCode: entry.languageCode, time)
    }
    
    private var conditionSymbolName: String {
        switch entry.snapshot.conditionCode {
            case 1000:
                return "sun.max.fill"
            case 1003, 1006, 1009:
                return "cloud.fill"
            case 1063, 1180...1201:
                return "cloud.rain.fill"
            case 1066, 1210...1225:
                return "snowflake"
            case 1087, 1273...1279:
                return "cloud.bolt.rain.fill"
            default:
                return "cloud.fill"
        }
    }
}

struct SkylightWeatherWidget: Widget {
    let kind: String = "SkylightWeatherWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: WeatherWidgetProvider()) { entry in
            WeatherWidgetEntryView(entry: entry)
        }
        .configurationDisplayName(
            WidgetL10n.text(.displayName, languageCode: WidgetL10n.currentLanguageCode())
        )
        .description(
            WidgetL10n.text(.description, languageCode: WidgetL10n.currentLanguageCode())
        )
        .contentMarginsDisabled()
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

@main
struct SkylightWeatherWidgetBundle: WidgetBundle {
    var body: some Widget {
        SkylightWeatherWidget()
    }
}
