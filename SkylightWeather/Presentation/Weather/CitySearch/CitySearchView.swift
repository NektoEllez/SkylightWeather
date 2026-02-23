    //
    //  CitySearchView.swift
    //  SkylightWeather
    //

import SwiftUI

struct CitySearchView: View {
    @Environment(\.appSettings) private var settings
    @State private var viewModel: CitySearchViewModel
    @FocusState private var isSearchFocused: Bool
    
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
        VStack(spacing: 8) {
            searchField

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
                            HStack(spacing: 0) {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(suggestion.title)
                                        .font(.body.weight(.semibold))

                                    if !suggestion.subtitle.isEmpty {
                                        Text(suggestion.subtitle)
                                            .font(.footnote)
                                            .foregroundStyle(.secondary)
                                    }
                                }
                                Spacer(minLength: 0)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .contentShape(Rectangle())
                        }
                        .buttonStyle(.plain)
                        .accessibilityIdentifier("city_search_suggestion_\(suggestion.id)")
                    }
                }
            }
            .accessibilityIdentifier("city_search_list")
            .listStyle(.plain)
        }
        .navigationTitle(settings.string(.citySelectionTitle))
        .navigationBarTitleDisplayMode(.inline)
        .textInputAutocapitalization(.words)
        .autocorrectionDisabled(true)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onAppear {
            Task { @MainActor in
                isSearchFocused = true
            }
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

    private var searchField: some View {
        HStack(spacing: 10) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)

            TextField(
                settings.string(.cityPlaceholder),
                text: Binding(
                    get: { viewModel.query },
                    set: { viewModel.updateQuery($0) }
                )
            )
            .focused($isSearchFocused)
            .submitLabel(.search)
            .onSubmit {
                submitManualCity()
            }

            if !trimmedQuery.isEmpty {
                Button {
                    HapticManager.shared.lightImpact()
                    viewModel.updateQuery("")
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .accessibilityIdentifier("city_search_clear_button")
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 14, style: .continuous))
        .padding(.horizontal, 12)
        .padding(.top, 4)
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
