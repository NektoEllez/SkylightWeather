    //
    //  AppLocalizedString.swift
    //  SkylightWeather
    //

import Foundation

enum AppLocalizedString: Hashable {
    case appTitle
    case sourcePrefixFormat
    case sourceCurrentLocation
    case sourceEnterCity
    case sourceQuickSelection
    case citySelectionTitle
    case citySelectionMessage
    case cityPlaceholder
    case citySearchStartTyping
    case citySearchNoResults
    case citySearchLoading
    case cancel
    case showWeather
    case retry
    case now
    case hourlyForecast
    case weeklyForecast
    case forecastDaysFormat
    case feelsLikeFormat
    case today
    case settings
    case done
    case appearance
    case language
    case system
    case light
    case dark
    case chooseColorScheme
    case selectLanguage
    case languageEnglish
    case languageRussian
    case errorInvalidURL
    case errorNoInternet
    case errorServerFormat
    case errorDecoding
    case errorCityNotFound
    case invalidCityWarning
    case errorUnknown
    case ok
    case widgetPlaceholderCondition
    case widgetUpdatedFormat
    case widgetDisplayName
    case widgetDescription
    case widgetSectionTitle
    case widgetAddInstructions
    case widgetHintToggle
    case quickCityMoscow
    case quickCitySaintPetersburg
    case quickCityKazan
    case quickCityNovosibirsk
    case quickCitySochi
    case precipitationChanceShort
    case humidityShort
    case windSpeedShort
    case windUnit

    func localized(for languageCode: String) -> String {
        let resolvedLanguage = L10n.resolveLanguageCode(languageCode)
        return Self.translations[self]?[resolvedLanguage] ?? Self.translations[self]?[L10n.fallbackLanguageCode] ?? ""
    }
}

private extension AppLocalizedString {
    static let translations: [AppLocalizedString: [String: String]] = [
            .appTitle: [
                "en": "Skylight Weather",
                "ru": "Skylight Weather"
            ],
            .sourcePrefixFormat: [
                "en": "Source: %@",
                "ru": "Источник: %@"
            ],
            .sourceCurrentLocation: [
                "en": "My location",
                "ru": "Моя геолокация"
            ],
            .sourceEnterCity: [
                "en": "Enter city",
                "ru": "Ввести город"
            ],
            .sourceQuickSelection: [
                "en": "Quick selection",
                "ru": "Быстрый выбор"
            ],
            .citySelectionTitle: [
                "en": "City selection",
                "ru": "Выбор города"
            ],
            .citySelectionMessage: [
                "en": "Enter a city for forecast",
                "ru": "Введите город для прогноза"
            ],
            .cityPlaceholder: [
                "en": "For example, Moscow",
                "ru": "Например, Москва"
            ],
            .citySearchStartTyping: [
                "en": "Start typing a city name",
                "ru": "Начните вводить название города"
            ],
            .citySearchNoResults: [
                "en": "No suggestions found",
                "ru": "Подсказки не найдены"
            ],
            .citySearchLoading: [
                "en": "Searching...",
                "ru": "Поиск..."
            ],
            .cancel: [
                "en": "Cancel",
                "ru": "Отмена"
            ],
            .showWeather: [
                "en": "Show",
                "ru": "Показать"
            ],
            .retry: [
                "en": "Retry",
                "ru": "Повторить"
            ],
            .now: [
                "en": "Now",
                "ru": "Сейчас"
            ],
            .hourlyForecast: [
                "en": "Hourly forecast",
                "ru": "Почасовой прогноз"
            ],
            .weeklyForecast: [
                "en": "7-day forecast",
                "ru": "На неделю"
            ],
            .forecastDaysFormat: [
                "en": "%d-day forecast",
                "ru": "На %d дн."
            ],
            .feelsLikeFormat: [
                "en": "Feels like %d°",
                "ru": "Ощущается как %d°"
            ],
            .today: [
                "en": "Today",
                "ru": "Сегодня"
            ],
            .settings: [
                "en": "Settings",
                "ru": "Настройки"
            ],
            .done: [
                "en": "Done",
                "ru": "Готово"
            ],
            .appearance: [
                "en": "Appearance",
                "ru": "Внешний вид"
            ],
            .language: [
                "en": "Language",
                "ru": "Язык"
            ],
            .system: [
                "en": "System",
                "ru": "Системная"
            ],
            .light: [
                "en": "Light",
                "ru": "Светлая"
            ],
            .dark: [
                "en": "Dark",
                "ru": "Темная"
            ],
            .chooseColorScheme: [
                "en": "Choose preferred color scheme",
                "ru": "Выберите цветовую схему"
            ],
            .selectLanguage: [
                "en": "Select preferred language",
                "ru": "Выберите язык"
            ],
            .languageEnglish: [
                "en": "English",
                "ru": "English"
            ],
            .languageRussian: [
                "en": "Russian",
                "ru": "Русский"
            ],
            .errorInvalidURL: [
                "en": "Invalid request URL",
                "ru": "Некорректный URL запроса"
            ],
            .errorNoInternet: [
                "en": "No internet connection",
                "ru": "Нет соединения с интернетом"
            ],
            .errorServerFormat: [
                "en": "Server error: %d",
                "ru": "Ошибка сервера: %d"
            ],
            .errorDecoding: [
                "en": "Failed to decode response",
                "ru": "Ошибка обработки данных"
            ],
            .errorCityNotFound: [
                "en": "City not found",
                "ru": "Город не найден"
            ],
            .invalidCityWarning: [
                "en": "It looks like this city name is incorrect. Please check spelling.",
                "ru": "Похоже, такого города нет. Проверьте, правильно ли введено название."
            ],
            .errorUnknown: [
                "en": "Unknown error",
                "ru": "Неизвестная ошибка"
            ],
            .ok: [
                "en": "OK",
                "ru": "Окей"
            ],
            .widgetPlaceholderCondition: [
                "en": "Open the app",
                "ru": "Откройте приложение"
            ],
            .widgetUpdatedFormat: [
                "en": "Updated %@",
                "ru": "Обновлено %@"
            ],
            .widgetDisplayName: [
                "en": "Skylight Weather",
                "ru": "Skylight Weather"
            ],
            .widgetDescription: [
                "en": "Current weather and short status",
                "ru": "Текущая погода и краткий статус"
            ],
            .widgetSectionTitle: [
                "en": "Home Screen Widget",
                "ru": "Виджет на главный экран"
            ],
            .widgetAddInstructions: [
                "en": "1. Long press on the Home Screen\n2. Tap the + button\n3. Find \"Skylight Weather\" and tap Add Widget",
                "ru": "1. Долгое нажатие на главный экран\n2. Нажмите кнопку +\n3. Найдите «Skylight Weather» и нажмите «Добавить виджет»"
            ],
            .widgetHintToggle: [
                "en": "Show widget instructions",
                "ru": "Показывать подсказку по виджету"
            ],
            .quickCityMoscow: [
                "en": "Moscow",
                "ru": "Москва"
            ],
            .quickCitySaintPetersburg: [
                "en": "Saint Petersburg",
                "ru": "Санкт-Петербург"
            ],
            .quickCityKazan: [
                "en": "Kazan",
                "ru": "Казань"
            ],
            .quickCityNovosibirsk: [
                "en": "Novosibirsk",
                "ru": "Новосибирск"
            ],
            .quickCitySochi: [
                "en": "Sochi",
                "ru": "Сочи"
            ],
            .precipitationChanceShort: [
                "en": "Rain",
                "ru": "Осадки"
            ],
            .humidityShort: [
                "en": "Humidity",
                "ru": "Влажность"
            ],
            .windSpeedShort: [
                "en": "Wind",
                "ru": "Ветер"
            ],
            .windUnit: [
                "en": "km/h",
                "ru": "км/ч"
            ]
        ]
}

enum L10n {
    static let fallbackLanguageCode = "en"
    static let supportedLanguageCodes: Set<String> = ["en", "ru"]
    
    static func text(_ key: AppLocalizedString, languageCode: String? = nil) -> String {
        key.localized(for: resolveLanguageCode(languageCode ?? currentLanguageCode()))
    }
    
    static func format(
        _ key: AppLocalizedString,
        languageCode: String? = nil,
        _ arguments: CVarArg...
    ) -> String {
        let code = resolveLanguageCode(languageCode ?? currentLanguageCode())
        let format = key.localized(for: code)
        return String(format: format, locale: locale(for: code), arguments: arguments)
    }
    
    static func currentLanguageCode() -> String {
        let defaults = UserDefaults(suiteName: SharedStorageKeys.appGroup) ?? .standard
        let storedCode = defaults.string(forKey: SharedStorageKeys.languageCode)
        return resolveLanguageCode(storedCode)
    }
    
    static func locale(for languageCode: String? = nil) -> Locale {
        Locale(identifier: resolveLanguageCode(languageCode ?? currentLanguageCode()))
    }
    
    static func resolveLanguageCode(_ languageCode: String?) -> String {
        LanguageCodeResolver.resolve(
            languageCode,
            supported: supportedLanguageCodes,
            fallback: fallbackLanguageCode
        )
    }
}
