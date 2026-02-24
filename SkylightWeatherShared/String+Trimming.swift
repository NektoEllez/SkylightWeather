import Foundation

extension String {
    nonisolated var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }

    nonisolated var trimmedOrNil: String? {
        let value = trimmed
        return value.isEmpty ? nil : value
    }
}
