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
        
        if let normalized = initialQuery.trimmedOrNil {
            updateQuery(normalized)
        }
    }
    
    func updateQuery(_ value: String) {
        query = value
        scheduleSearch(for: value)
    }
    
    private func scheduleSearch(for rawQuery: String) {
        debounceTask?.cancel()
        
        guard let trimmed = rawQuery.trimmedOrNil else {
            suggestions = []
            isLoading = false
            completer.queryFragment = ""
            return
        }
        
        isLoading = true
        debounceTask = Task { [weak self] in
            do {
                try await Task.sleep(for: .milliseconds(250))
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
        guard let normalizedTitle = completion.title.trimmedOrNil else { return nil }
        let normalizedSubtitle = completion.subtitle.trimmed
        
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
