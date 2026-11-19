import Foundation

/// The languages Tend is translated into, so a stock name saved in one language
/// can still be recognised after the phone switches to another.
nonisolated enum Languages {
    static let codes = ["en", "cs", "uk"]

    /// One resource bundle per language. A language that is missing is skipped.
    static var bundles: [Bundle] {
        codes.compactMap { code in
            Bundle.main.path(forResource: code, ofType: "lproj").flatMap(Bundle.init(path:))
        }
    }

    /// What `text` says in each language.
    static func variants(_ text: (Bundle) -> String) -> Set<String> {
        Set(bundles.map(text))
    }
}
