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

    #if os(macOS)
    private var macControlInsets: EdgeInsets {
        EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16)
    }

    private var macFooterInsets: EdgeInsets {
        EdgeInsets(top: 0, leading: 16, bottom: 8, trailing: 16)
    }
    #endif

    private var appearanceSelection: Binding<String> {
        Binding(
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
    }

    private var languageSelection: Binding<String> {
        Binding(
            get: { settings.languageCode },
            set: {
                HapticManager.shared.selectionChanged()
                settings.languageCode = $0
            }
        )
    }

    var body: some View {
        Group {
            #if os(macOS)
            macContent
            #else
            iOSContent
            #endif
        }
        .accessibilityIdentifier("settings_form")
        .navigationTitle(settings.string(.settings))
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
        .toolbar {
            #if os(iOS)
            ToolbarItem(placement: .topBarTrailing) {
                doneButton
            }
            #else
            ToolbarItem(placement: .confirmationAction) {
                doneButton
            }
            #endif
        }
        .onChange(of: settings.colorScheme) { _, _ in
            onSheetColorSchemeChange?()
        }
    }

    private var doneButton: some View {
        Button(settings.string(.done)) {
            HapticManager.shared.lightImpact()
            onDone()
        }
        .accessibilityIdentifier("settings_done_button")
    }

    #if os(iOS)
    private var iOSContent: some View {
        Form {
            appearanceSection
            languageSection
            widgetSection
        }
        .scrollContentBackground(.hidden)
        .background(sheetMaterial)
    }
    #endif

    #if os(macOS)
    private var macContent: some View {
        Form {
            Section(settings.string(.appearance)) {
                Picker("", selection: appearanceSelection) {
                    Text(settings.string(.system)).tag("system")
                    Text(settings.string(.light)).tag("light")
                    Text(settings.string(.dark)).tag("dark")
                }
                .pickerStyle(.segmented)
                .labelsHidden()
                    .frame(maxWidth: 320, alignment: .leading)
                    .accessibilityIdentifier("settings_appearance_picker")
                    .listRowInsets(macControlInsets)

                Text(settings.string(.chooseColorScheme))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .listRowInsets(macFooterInsets)
            }

            Section(settings.string(.language)) {
                Picker("", selection: languageSelection) {
                    ForEach(AppSettings.availableLanguages, id: \.code) { language in
                        Text(settings.string(language.key)).tag(language.code)
                    }
                }
                .pickerStyle(.menu)
                .labelsHidden()
                    .frame(width: 180)
                    .accessibilityIdentifier("settings_language_picker")
                    .listRowInsets(macControlInsets)

                Text(settings.string(.selectLanguage))
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .listRowInsets(macFooterInsets)
            }

            Section(settings.string(.widgetSectionTitle)) {
                Toggle(settings.string(.widgetHintToggle), isOn: Binding(
                    get: { settings.showWidgetHint },
                    set: {
                        HapticManager.shared.selectionChanged()
                        settings.showWidgetHint = $0
                    }
                ))
                .toggleStyle(.checkbox)
                .accessibilityIdentifier("settings_widget_hint_toggle")
                .listRowInsets(macControlInsets)

                if settings.showWidgetHint {
                    Text(settings.string(.widgetAddInstructions))
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .listRowInsets(macFooterInsets)
                }
            }
        }
        .formStyle(.grouped)
        .scrollContentBackground(.hidden)
        .background(sheetMaterial)
    }
    #endif

    private var appearancePicker: some View {
        Picker(settings.string(.appearance), selection: appearanceSelection) {
            Text(settings.string(.system)).tag("system")
            Text(settings.string(.light)).tag("light")
            Text(settings.string(.dark)).tag("dark")
        }
        .pickerStyle(.segmented)
        .accessibilityIdentifier("settings_appearance_picker")
    }

    private var languagePicker: some View {
        Picker(settings.string(.language), selection: languageSelection) {
            ForEach(AppSettings.availableLanguages, id: \.code) { language in
                Text(settings.string(language.key)).tag(language.code)
            }
        }
        .pickerStyle(.menu)
        .accessibilityIdentifier("settings_language_picker")
    }

    private var appearanceSection: some View {
        Section {
            appearancePicker
        } header: {
            Text(settings.string(.appearance))
        } footer: {
            Text(settings.string(.chooseColorScheme))
        }
    }

    private var languageSection: some View {
        Section {
            languagePicker
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
            .accessibilityIdentifier("settings_widget_hint_toggle")

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
