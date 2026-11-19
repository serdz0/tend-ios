import Foundation

/// The colour group an item belongs to on the calendar. Each also has its own icon,
/// so colour is never the only clue.
enum CareCategory: CaseIterable {
    case plant
    case inspection
    case insurance
    case tyres
    case service
    case cleaning
    case other

    init(item: CareItem) {
        guard item.kind == .car else {
            self = .plant
            return
        }
        switch item.task {
        case CarTaskPreset.stk.taskName: self = .inspection
        case CarTaskPreset.insurance.taskName: self = .insurance
        case CarTaskPreset.winterTyres.taskName, CarTaskPreset.summerTyres.taskName: self = .tyres
        case CarTaskPreset.oilService.taskName, CarTaskPreset.brakeFluid.taskName,
             CarTaskPreset.filtersAndWipers.taskName, CarTaskPreset.batteryCheck.taskName: self = .service
        case CarTaskPreset.tyrePressure.taskName: self = .tyres
        case CarTaskPreset.washExterior.taskName, CarTaskPreset.cleanInterior.taskName: self = .cleaning
        default: self = .other
        }
    }

    var title: String {
        switch self {
        case .plant: String(localized: "Plants")
        case .inspection: String(localized: "Inspection")
        case .insurance: String(localized: "Insurance")
        case .tyres: String(localized: "Tyres")
        case .service: String(localized: "Servicing")
        case .cleaning: String(localized: "Cleaning")
        case .other: String(localized: "Other")
        }
    }

    var symbolName: String {
        switch self {
        case .plant: "leaf"
        case .inspection: "checkmark.seal"
        case .insurance: "shield"
        case .tyres: "arrow.triangle.2.circlepath"
        case .service: "wrench.and.screwdriver"
        case .cleaning: "bubbles.and.sparkles"
        case .other: "checklist"
        }
    }
}
