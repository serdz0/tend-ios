import Foundation

/// The colour group an item belongs to on the calendar. Each also has its own icon,
/// so colour is never the only clue.
enum CareCategory: CaseIterable {
    case plant
    case inspection
    case insurance
    case tyres
    case service
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
        case CarTaskPreset.oilService.taskName: self = .service
        default: self = .other
        }
    }

    var title: String {
        switch self {
        case .plant: "Plants"
        case .inspection: "Inspection"
        case .insurance: "Insurance"
        case .tyres: "Tyres"
        case .service: "Servicing"
        case .other: "Other"
        }
    }

    var symbolName: String {
        switch self {
        case .plant: "leaf"
        case .inspection: "checkmark.seal"
        case .insurance: "shield"
        case .tyres: "arrow.triangle.2.circlepath"
        case .service: "wrench.and.screwdriver"
        case .other: "checklist"
        }
    }
}
