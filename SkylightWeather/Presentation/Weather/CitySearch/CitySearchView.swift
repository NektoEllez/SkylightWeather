    //
    //  CitySearchView.swift
    //  SkylightWeather
    //

import SwiftUI

struct CitySearchView: View {
    @Environment(\.appSettings) private var settings
    @State private var viewModel: CitySearchViewModel
    
    let onSelect: (String) -> Void
    let onCancel: () -> Void
    
    init(
        initialQuery: String? = nil,
        onSelect: @escaping (String) -> Void,
        onCancel: @escaping () -> Void
    ) {
        _viewModel = State(initialValue: CitySearchViewModel(initialQuery: initialQuery ?? ""))
        self.onSelect = onSelect
        self.onCancel = onCancel
    }
    
    var body: some View {
        List {
            if trimmedQuery.isEmpty {
                hintRow(settings.string(.citySearchStartTyping))
            } else if viewModel.suggestions.isEmpty {
                hintRow(viewModel.isLoading ? settings.string(.citySearchLoading) : settings.string(.citySearchNoResults))
            } else {
                ForEach(viewModel.suggestions) { suggestion in
                    Button {
                        HapticManager.shared.selectionChanged()
                        onSelect(suggestion.query)
                    } label: {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(suggestion.title)
                                .font(.body.weight(.semibold))
                            
                            if !suggestion.subtitle.isEmpty {
                                Text(suggestion.subtitle)
                                    .font(.footnote)
                                    .foregroundStyle(.secondary)
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    .buttonStyle(.plain)
                    .accessibilityIdentifier("city_search_suggestion_\(suggestion.id)")
                }
            }
        }
        .accessibilityIdentifier("city_search_list")
        .listStyle(.plain)
        .navigationTitle(settings.string(.citySelectionTitle))
        .navigationBarTitleDisplayMode(.inline)
        .searchable(
            text: Binding(
                get: { viewModel.query },
                set: { viewModel.updateQuery($0) }
            ),
            placement: .navigationBarDrawer(displayMode: .always),
            prompt: settings.string(.cityPlaceholder)
        )
        .textInputAutocapitalization(.words)
        .autocorrectionDisabled(true)
        .onSubmit(of: .search) {
            submitManualCity()
        }
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button(settings.string(.cancel)) {
                    HapticManager.shared.lightImpact()
                    onCancel()
                }
                .accessibilityIdentifier("city_search_cancel_button")
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(settings.string(.showWeather)) {
                    submitManualCity()
                }
                .disabled(trimmedQuery.isEmpty)
                .accessibilityIdentifier("city_search_submit_button")
            }
        }
    }
    
    private var trimmedQuery: String {
        viewModel.query.trimmingCharacters(in: .whitespacesAndNewlines)
    }
    
    private func hintRow(_ text: String) -> some View {
        Text(text)
            .foregroundStyle(.secondary)
            .frame(maxWidth: .infinity, alignment: .center)
            .listRowSeparator(.hidden)
    }
    
    private func submitManualCity() {
        guard !trimmedQuery.isEmpty else { return }
        HapticManager.shared.mediumImpact()
        onSelect(trimmedQuery)
    }
}

#Preview {
    NavigationStack {
        CitySearchView(onSelect: { _ in }, onCancel: {})
            .environment(\.appSettings, AppSettings.shared)
    }
}
