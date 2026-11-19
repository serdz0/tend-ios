import Foundation

/// The car tasks the form offers, each with its own way of repeating.
enum CarTaskPreset: String, CaseIterable, Identifiable {
    case stk
    case insurance
    case winterTyres
    case summerTyres
    case oilService
    case custom

    var id: Self { self }

    /// Task name on the Today screen. Empty for a custom task, which you name yourself.
    var taskName: String {
        switch self {
        case .stk: "STK inspection"
        case .insurance: "Insurance renewal"
        case .winterTyres: "Fit winter tyres"
        case .summerTyres: "Fit summer tyres"
        case .oilService: "Oil service"
        case .custom: ""
        }
    }

    /// How the picker names it.
    var displayName: String {
        self == .custom ? "Other task" : taskName
    }

    var scheduleStyle: ScheduleStyle {
        switch self {
        case .stk: .interval(Recurrence(count: 2, unit: .year))
        case .insurance: .interval(Recurrence(count: 1, unit: .year))
        // Winter tyres must be on before 1 November, so the last good day is 31 October.
        case .winterTyres: .yearly(month: 10, day: 31)
        // Summer tyres go on "around" 1 April.
        case .summerTyres: .yearly(month: 4, day: 1)
        case .oilService: .distance(intervalKm: 15_000)
        case .custom: .interval(Recurrence(count: 1, unit: .year))
        }
    }
}
