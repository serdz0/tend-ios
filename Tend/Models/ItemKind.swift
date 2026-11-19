import Foundation

/// What kind of thing is being looked after.
nonisolated enum ItemKind: String, Codable, CaseIterable, Identifiable {
    case plant
    case car

    var id: Self { self }

    var title: String {
        switch self {
        case .plant: String(localized: "Plant")
        case .car: String(localized: "Car")
        }
    }

    /// SF Symbol that tells plants and car tasks apart without relying on colour.
    var symbolName: String {
        switch self {
        case .plant: "leaf"
        case .car: "car"
        }
    }
}
