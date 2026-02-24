import Foundation

enum LanguageCodeResolver {
    static func resolve(
        _ languageCode: String?,
        supported: Set<String>,
        fallback: String,
        preferredLanguages: [String] = Locale.preferredLanguages
    ) -> String {
        if let normalized = languageCode?.lowercased(), supported.contains(normalized) {
            return normalized
        }

        if let preferred = preferredLanguages.first?.prefix(2).lowercased(),
           supported.contains(preferred) {
            return preferred
        }

        return fallback
    }
}
