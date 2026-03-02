//
//  WeatherView.swift
//  SkylightWeather
//

import SwiftUI
import os

struct WeatherView: View {

    @Environment(\.appSettings) private var appSettings
    @State private var viewModel = WeatherViewModel()
    @State private var showSettings = false
    @State private var showCitySearch = false
    @State private var isLoadingVisible = false
    @State private var lastObservedLanguageCode: String?
    @State private var nextAllowedRefreshAt: Date = .distantPast
    @State private var refreshThrottleTask: Task<Void, Never>?

    var body: some View {
        NavigationStack {
            ZStack {
                weatherContent

                if isLoadingVisible {
                    GlobalLoadingOverlay()
                        .transition(.opacity)
                }
            }
            .animation(.easeInOut(duration: 0.18), value: isLoadingVisible)
            .navigationTitle(appSettings.string(.appTitle))
            #if os(iOS)
            .navigationBarTitleDisplayMode(.inline)
            #endif
            .toolbar { toolbarContent }
        }
        .task {
            lastObservedLanguageCode = appSettings.languageCode
            viewModel.loadWeather()
        }
        .onChange(of: viewModel.isLoading) { _, isLoading in
            updateLoadingVisibility(isLoading: isLoading)
        }
        .onChange(of: appSettings.languageCode) { _, newValue in
            if lastObservedLanguageCode != newValue {
                lastObservedLanguageCode = newValue
                viewModel.loadWeather()
            }
        }
        .sheet(isPresented: $showSettings) {
            settingsSheet
        }
        .sheet(isPresented: $showCitySearch) {
            citySearchSheet
        }
        .onDisappear {
            refreshThrottleTask?.cancel()
            refreshThrottleTask = nil
            viewModel.cancelLoading()
        }
    }

    // MARK: - Weather Content

    private var weatherContent: some View {
        WeatherHostedContent(
            state: viewModel.state,
            lastContent: viewModel.lastSuccessfulData,
            onRetry: {
                HapticManager.shared.lightImpact()
                Task { @MainActor in
                    try? await Task.sleep(for: .seconds(0.2))
                    viewModel.loadWeather()
                }
            },
            onAcknowledgeInvalidCity: {
                HapticManager.shared.warning()
                viewModel.acknowledgeInvalidCityWarning()
            },
            appSettings: appSettings
        )
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .primaryAction) {
            sourceMenu
        }
        ToolbarItem(placement: .primaryAction) {
            Button {
                refreshTapped()
            } label: {
                Image(systemName: "arrow.clockwise")
            }
            .accessibilityIdentifier("nav_refresh_button")
        }
        #if os(iOS)
        ToolbarItem(placement: .topBarLeading) {
            settingsButton
        }
        #else
        ToolbarItem(placement: .primaryAction) {
            settingsButton
        }
        #endif
    }

    private var settingsButton: some View {
        Button {
            HapticManager.shared.lightImpact()
            showSettings = true
        } label: {
            Image(systemName: "gearshape")
        }
        .accessibilityIdentifier("nav_settings_button")
    }

    private var sourceMenu: some View {
        Menu {
            Button {
                HapticManager.shared.selectionChanged()
                viewModel.useCurrentLocation()
            } label: {
                Label(appSettings.string(.sourceCurrentLocation), systemImage: "location.fill")
            }

            Button {
                HapticManager.shared.selectionChanged()
                showCitySearch = true
            } label: {
                Label(appSettings.string(.sourceEnterCity), systemImage: "magnifyingglass")
            }

            Section(appSettings.string(.sourceQuickSelection)) {
                ForEach(quickCities, id: \.self) { city in
                    Button(city) {
                        HapticManager.shared.selectionChanged()
                        viewModel.useCity(city)
                    }
                }
            }
        } label: {
            Image(systemName: "location.magnifyingglass")
        }
        .accessibilityIdentifier("nav_source_button")
    }

    // MARK: - Sheets

    private var settingsSheet: some View {
        NavigationStack {
            SettingsView(onDone: {
                showSettings = false
            })
            .environment(\.appSettings, appSettings)
        }
        #if os(iOS)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        #else
        .frame(minWidth: 480, minHeight: 500)
        #endif
    }

    private var citySearchSheet: some View {
        NavigationStack {
            CitySearchView(
                onSelect: { query in
                    showCitySearch = false
                    viewModel.useCity(query)
                },
                onCancel: {
                    showCitySearch = false
                }
            )
            .environment(\.appSettings, appSettings)
        }
        #if os(iOS)
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
        #else
        .frame(minWidth: 360, minHeight: 400)
        #endif
    }

    // MARK: - Helpers

    private var quickCities: [String] {
        [
            appSettings.string(.quickCityMoscow),
            appSettings.string(.quickCitySaintPetersburg),
            appSettings.string(.quickCityKazan),
            appSettings.string(.quickCityNovosibirsk),
            appSettings.string(.quickCitySochi)
        ]
    }

    private func refreshTapped() {
        let now = Date()
        guard now >= nextAllowedRefreshAt else { return }
        nextAllowedRefreshAt = now.addingTimeInterval(2)

        HapticManager.shared.lightImpact()
        isLoadingVisible = true

        refreshThrottleTask?.cancel()
        refreshThrottleTask = Task { @MainActor in
            defer { refreshThrottleTask = nil }
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            viewModel.loadWeather()
        }
    }

    private func updateLoadingVisibility(isLoading: Bool) {
        isLoadingVisible = isLoading
    }

}

// MARK: - Preview

#Preview {
    WeatherView()
        .environment(\.appSettings, AppSettings.shared)
}
