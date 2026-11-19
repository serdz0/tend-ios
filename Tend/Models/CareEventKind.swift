import Foundation

nonisolated enum CareEventKind: String, Codable {
    case done
    case snoozed

    /// The word shown in the history. Always words, never colour alone.
    var title: String {
        switch self {
        case .done: String(localized: "Done")
        case .snoozed: String(localized: "Snoozed")
        }
    }

    var symbolName: String {
        switch self {
        case .done: "checkmark.circle"
        case .snoozed: "zzz"
        }
    }
}
