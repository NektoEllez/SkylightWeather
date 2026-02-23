//
//  CitySearchViewModel.swift
//  SkylightWeather
//

import Foundation
import MapKit
import Observation
import os

@MainActor
@Observable
final class CitySearchViewModel: NSObject {
    var query: String
    var suggestions: [CitySearchSuggestion] = []
    var isLoading = false

    private let completer = MKLocalSearchCompleter()
    private let logger = AppLog.ui
    private var debounceTask: Task<Void, Never>?

    init(initialQuery: String = "") {
        self.query = initialQuery
        super.init()

        completer.delegate = self
        completer.resultTypes = [.address, .query]

        if !initialQuery.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            updateQuery(initialQuery)
        }
    }

    func updateQuery(_ value: String) {
        query = value
        scheduleSearch(for: value)
    }

    private func scheduleSearch(for rawQuery: String) {
        debounceTask?.cancel()

        let trimmed = rawQuery.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else {
            suggestions = []
            isLoading = false
            completer.queryFragment = ""
            return
        }

        isLoading = true
        debounceTask = Task { [weak self] in
            do {
                try await Task.sleep(nanoseconds: 250_000_000)
            } catch {
                return
            }
            guard !Task.isCancelled else { return }
            self?.performSearch(query: trimmed)
        }
    }

    private func performSearch(query: String) {
        completer.queryFragment = query
    }

    private func applyResults(_ results: [MKLocalSearchCompletion]) {
        var seenQueries = Set<String>()
        suggestions = results
            .compactMap(CitySearchSuggestion.init(completion:))
            .filter { seenQueries.insert($0.queryKey).inserted }
        isLoading = false
    }

    private func handleCompletionError(_ error: Error) {
        logger.error("City suggestions failed: \(error.localizedDescription, privacy: .public)")
        suggestions = []
        isLoading = false
    }
}

extension CitySearchViewModel: MKLocalSearchCompleterDelegate {
    nonisolated func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        let results = completer.results
        Task { @MainActor [weak self] in
            self?.applyResults(results)
        }
    }

    nonisolated func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        Task { @MainActor [weak self] in
            self?.handleCompletionError(error)
        }
    }
}

struct CitySearchSuggestion: Identifiable, Hashable {
    let id: String
    let title: String
    let subtitle: String
    let query: String
    let queryKey: String

    init?(completion: MKLocalSearchCompletion) {
        let normalizedTitle = completion.title.trimmingCharacters(in: .whitespacesAndNewlines)
        let normalizedSubtitle = completion.subtitle.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !normalizedTitle.isEmpty else { return nil }

        title = normalizedTitle
        subtitle = normalizedSubtitle

        if normalizedSubtitle.isEmpty {
            query = normalizedTitle
        } else {
            query = "\(normalizedTitle), \(normalizedSubtitle)"
        }

        let key = "\(normalizedTitle.lowercased())|\(normalizedSubtitle.lowercased())"
        id = key
        queryKey = key
    }
}
