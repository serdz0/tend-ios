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
        case .basil: String(localized: "Basil or herbs")
        case .succulent: String(localized: "Cactus or succulent")
        case .other: String(localized: "Other plant")
        default: defaultName
        }
    }

    /// Suggested name for the plant. Empty for "other", because only you know what it is.
    var defaultName: String {
        defaultName(in: .main)
    }

    /// The suggested name in one language, given by that language's resource bundle. Used to
    /// recognise a stock name that was filled in while the phone spoke another language.
    func defaultName(in bundle: Bundle) -> String {
        switch self {
        case .basil: String(localized: "Basil", bundle: bundle)
        case .monstera: String(localized: "Monstera", bundle: bundle)
        case .fiddleLeafFig: String(localized: "Fiddle leaf fig", bundle: bundle)
        case .peaceLily: String(localized: "Peace lily", bundle: bundle)
        case .orchid: String(localized: "Orchid", bundle: bundle)
        case .ficus: String(localized: "Ficus", bundle: bundle)
        case .pothos: String(localized: "Pothos", bundle: bundle)
        case .snakePlant: String(localized: "Snake plant", bundle: bundle)
        case .zzPlant: String(localized: "ZZ plant", bundle: bundle)
        case .aloeVera: String(localized: "Aloe vera", bundle: bundle)
        case .succulent: String(localized: "Succulent", bundle: bundle)
        case .dracaena: String(localized: "Dracaena", bundle: bundle)
        case .dipladenia: String(localized: "Dipladenia", bundle: bundle)
        case .campanula: String(localized: "Campanula", bundle: bundle)
        case .camellia: String(localized: "Camellia", bundle: bundle)
        case .strelitzia: String(localized: "Strelitzia", bundle: bundle)
        case .other: ""
        }
    }

    /// The stock name in every language the app speaks.
    var defaultNameInAnyLanguage: Set<String> {
        Languages.variants { defaultName(in: $0) }
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
        case .dipladenia: String(localized: "Thirsty in summer (every 3 to 4 days), much less in winter (every 2 to 3 weeks).")
        case .campanula: String(localized: "Likes even moisture in spring and summer, and less in winter.")
        case .dracaena, .strelitzia: String(localized: "Water a little less often in winter.")
        default: nil
        }
    }
}
