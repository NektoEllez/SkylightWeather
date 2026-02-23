//
//  SettingsView.swift
//  SkylightWeather
//

import SwiftUI

struct SettingsView: View {
    @Environment(\.appSettings) private var settings
    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.onSheetColorSchemeChange) private var onSheetColorSchemeChange
    private let onDone: () -> Void

    init(onDone: @escaping () -> Void = {}) {
        self.onDone = onDone
    }

    private var sheetMaterial: Material {
        colorScheme == .dark ? .regularMaterial : .ultraThinMaterial
    }

    var body: some View {
        Form {
            appearanceSection
            languageSection
            widgetSection
        }
        .scrollContentBackground(.hidden)
        .background(sheetMaterial)
        .navigationTitle(settings.string(.settings))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(settings.string(.done)) {
                    HapticManager.shared.lightImpact()
                    onDone()
                }
            }
        }
        .onChange(of: settings.colorScheme) { _, _ in
            onSheetColorSchemeChange?()
        }
    }

    private var appearanceSection: some View {
        Section {
            Picker(
                settings.string(.appearance),
                selection: Binding(
                    get: {
                        switch settings.colorScheme {
                        case .light:
                            return "light"
                        case .dark:
                            return "dark"
                        default:
                            return "system"
                        }
                    },
                    set: { selection in
                        HapticManager.shared.selectionChanged()
                        switch selection {
                        case "light":
                            settings.colorScheme = .light
                        case "dark":
                            settings.colorScheme = .dark
                        default:
                            settings.colorScheme = nil
                        }
                    }
                )
            ) {
                Text(settings.string(.system)).tag("system")
                Text(settings.string(.light)).tag("light")
                Text(settings.string(.dark)).tag("dark")
            }
            .pickerStyle(.segmented)
        } header: {
            Text(settings.string(.appearance))
        } footer: {
            Text(settings.string(.chooseColorScheme))
        }
    }

    private var languageSection: some View {
        Section {
            Picker(
                settings.string(.language),
                selection: Binding(
                    get: { settings.languageCode },
                    set: {
                        HapticManager.shared.selectionChanged()
                        settings.languageCode = $0
                    }
                )
            ) {
                ForEach(AppSettings.availableLanguages, id: \.code) { language in
                    Text(settings.string(language.key)).tag(language.code)
                }
            }
            .pickerStyle(.menu)
        } header: {
            Text(settings.string(.language))
        } footer: {
            Text(settings.string(.selectLanguage))
        }
    }

    private var widgetSection: some View {
        Section {
            Toggle(settings.string(.widgetHintToggle), isOn: Binding(
                get: { settings.showWidgetHint },
                set: {
                    HapticManager.shared.selectionChanged()
                    settings.showWidgetHint = $0
                }
            ))
            if settings.showWidgetHint {
                Text(settings.string(.widgetAddInstructions))
                    .font(.footnote)
            }
        } header: {
            Text(settings.string(.widgetSectionTitle))
        }
    }
}

#Preview {
    NavigationStack {
        SettingsView()
            .environment(\.appSettings, AppSettings.shared)
    }
}
