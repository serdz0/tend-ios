import Foundation

/// Kinds of plant with a starting watering interval. These are rules of thumb: pot, light and
/// season change what a plant really needs, so the interval can always be edited.
nonisolated enum PlantType: String, Codable, CaseIterable, Identifiable {
    case basil
    case monstera
    case fiddleLeafFig
    case peaceLily
    case orchid
    case ficus
    case pothos
    case snakePlant
    case zzPlant
    case aloeVera
    case succulent
    case other

    var id: Self { self }

    /// How the type appears in the picker.
    var displayName: String {
        switch self {
        case .basil: "Basil or herbs"
        case .succulent: "Cactus or succulent"
        case .other: "Other plant"
        default: defaultName
        }
    }

    /// Suggested name for the plant. Empty for "other", because only you know what it is.
    var defaultName: String {
        switch self {
        case .basil: "Basil"
        case .monstera: "Monstera"
        case .fiddleLeafFig: "Fiddle leaf fig"
        case .peaceLily: "Peace lily"
        case .orchid: "Orchid"
        case .ficus: "Ficus"
        case .pothos: "Pothos"
        case .snakePlant: "Snake plant"
        case .zzPlant: "ZZ plant"
        case .aloeVera: "Aloe vera"
        case .succulent: "Succulent"
        case .other: ""
        }
    }

    /// Days between waterings. Nil for "other".
    var wateringDays: Int? {
        switch self {
        case .basil: 3
        case .monstera, .fiddleLeafFig, .peaceLily, .orchid, .ficus: 7
        case .pothos: 10
        case .snakePlant, .zzPlant, .aloeVera: 14
        case .succulent: 21
        case .other: nil
        }
    }
}
