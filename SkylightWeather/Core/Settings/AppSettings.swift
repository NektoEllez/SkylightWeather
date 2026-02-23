    //
    //  AppSettings.swift
    //  SkylightWeather
    //

import Observation
import SwiftUI

protocol Localizing: AnyObject {
    var languageCode: String { get }
    func string(_ key: AppLocalizedString) -> String
}

@MainActor
@Observable
final class AppSettings: Localizing {
    enum StorageKey {
        static let colorScheme = "app.colorScheme"
        static let languageCode = SharedStorageKeys.languageCode
        static let showWidgetHint = "app.showWidgetHint"
    }
    
    static let shared = AppSettings()
    
    static let availableLanguages: [(code: String, key: AppLocalizedString)] = [
        ("en", .languageEnglish),
        ("ru", .languageRussian)
    ]
    
    var colorScheme: ColorScheme? {
        didSet {
            let storedValue: String?
            switch colorScheme {
                case .light:
                    storedValue = "light"
                case .dark:
                    storedValue = "dark"
                case nil:
                    storedValue = nil
                @unknown default:
                    storedValue = nil
            }
            defaults.set(storedValue, forKey: StorageKey.colorScheme)
        }
    }
    
    var showWidgetHint: Bool {
        didSet {
            defaults.set(showWidgetHint, forKey: StorageKey.showWidgetHint)
        }
    }
    
    var languageCode: String {
        didSet {
            let resolved = L10n.resolveLanguageCode(languageCode)
            guard resolved == languageCode else {
                languageCode = resolved
                return
            }
            defaults.set(resolved, forKey: StorageKey.languageCode)
            defaults.set([resolved], forKey: "AppleLanguages")
        }
    }
    
    private let defaults: UserDefaults
    
    init(defaults: UserDefaults) {
        self.defaults = defaults
        
        let storedScheme = defaults.string(forKey: StorageKey.colorScheme)
        switch storedScheme {
            case "light":
                colorScheme = .light
            case "dark":
                colorScheme = .dark
            default:
                colorScheme = nil
        }
        
        showWidgetHint = defaults.object(forKey: StorageKey.showWidgetHint) as? Bool ?? true
        
        let storedLanguage = defaults.string(forKey: StorageKey.languageCode)
        languageCode = L10n.resolveLanguageCode(storedLanguage)
    }
    
    convenience init() {
        let sharedDefaults = UserDefaults(suiteName: SharedStorageKeys.appGroup) ?? .standard
        self.init(defaults: sharedDefaults)
    }
    
    func string(_ key: AppLocalizedString) -> String {
        key.localized(for: languageCode)
    }
}

private enum AppSettingsEnvironmentKey: EnvironmentKey {
    static let defaultValue = AppSettings.shared
}

extension EnvironmentValues {
    var appSettings: AppSettings {
        get { self[AppSettingsEnvironmentKey.self] }
        set { self[AppSettingsEnvironmentKey.self] = newValue }
    }
    
        /// Called when color scheme changes so the sheet can update its `overrideUserInterfaceStyle` instantly.
    var onSheetColorSchemeChange: (() -> Void)? {
        get { self[SheetColorSchemeChangeKey.self] }
        set { self[SheetColorSchemeChangeKey.self] = newValue }
    }
}

private struct SheetColorSchemeChangeKey: EnvironmentKey {
    static let defaultValue: (() -> Void)? = nil
}

extension ColorScheme? {
    var uiInterfaceStyle: UIUserInterfaceStyle {
        switch self {
            case .light: return .light
            case .dark: return .dark
            case nil: return .unspecified
            @unknown default: return .unspecified
        }
    }
}
