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
    case dracaena
    case dipladenia
    case campanula
    case camellia
    case strelitzia
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
        case .dracaena: "Dracaena"
        case .dipladenia: "Dipladenia"
        case .campanula: "Campanula"
        case .camellia: "Camellia"
        case .strelitzia: "Strelitzia"
        case .other: ""
        }
    }

    /// Days between waterings. Nil for "other".
    var wateringDays: Int? {
        switch self {
        case .basil: 3
        case .monstera, .fiddleLeafFig, .peaceLily, .orchid, .ficus: 7
        case .pothos, .dracaena, .strelitzia: 10
        case .dipladenia: 7
        case .campanula: 5
        case .camellia: 7
        case .snakePlant, .zzPlant, .aloeVera: 14
        case .succulent: 21
        case .other: nil
        }
    }

    /// Watering that changes with the season, for plants where care guides agree it matters a lot.
    var seasonalWatering: SeasonalWatering? {
        switch self {
        case .dipladenia: SeasonalWatering(growing: 4, shoulder: 7, rest: 14)
        case .dracaena, .strelitzia: SeasonalWatering(growing: 7, shoulder: 10, rest: 14)
        case .zzPlant: SeasonalWatering(growing: 14, shoulder: 18, rest: 25)
        default: nil
        }
    }

    /// A short tip for plants whose need changes a lot with the seasons. Most plants have none.
    var seasonTip: String? {
        switch self {
        case .dipladenia: "Thirsty in summer (every 3 to 4 days), much less in winter (every 2 to 3 weeks)."
        case .campanula: "Likes even moisture in spring and summer, and less in winter."
        case .dracaena, .strelitzia: "Water a little less often in winter."
        default: nil
        }
    }
}
