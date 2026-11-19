import Foundation

/// How the car task picker groups its choices.
nonisolated enum CarTaskGroup: CaseIterable, Identifiable {
    case deadlines
    case servicing
    case routine
    case yourOwn

    var id: Self { self }

    var title: String {
        switch self {
        case .deadlines: "Deadlines"
        case .servicing: "Servicing"
        case .routine: "Routine care"
        case .yourOwn: "Your own"
        }
    }

    var presets: [CarTaskPreset] {
        switch self {
        case .deadlines: [.stk, .insurance, .vignette, .firstAidKit]
        case .servicing: [.oilService, .brakeFluid, .filtersAndWipers, .batteryCheck, .winterTyres, .summerTyres]
        case .routine: [.washExterior, .cleanInterior, .tyrePressure]
        case .yourOwn: [.custom]
        }
    }
}

/// The car tasks the form offers, each with its own way of repeating.
nonisolated enum CarTaskPreset: String, CaseIterable, Identifiable {
    case stk
    case insurance
    case vignette
    case firstAidKit
    case oilService
    case brakeFluid
    case filtersAndWipers
    case batteryCheck
    case winterTyres
    case summerTyres
    case washExterior
    case cleanInterior
    case tyrePressure
    case custom

    var id: Self { self }

    /// Task name on the Today screen. Empty for a custom task, which you name yourself.
    var taskName: String {
        switch self {
        case .stk: "STK inspection"
        case .insurance: "Insurance renewal"
        case .vignette: "Highway vignette"
        case .firstAidKit: "Check the first-aid kit"
        case .oilService: "Oil service"
        case .brakeFluid: "Brake fluid change"
        case .filtersAndWipers: "Cabin filter and wipers"
        case .batteryCheck: "Check the car battery"
        case .winterTyres: "Fit winter tyres"
        case .summerTyres: "Fit summer tyres"
        case .washExterior: "Wash the car"
        case .cleanInterior: "Clean the interior"
        case .tyrePressure: "Check tyre pressure"
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
        case .insurance, .vignette, .firstAidKit, .filtersAndWipers: .interval(Recurrence(count: 1, unit: .year))
        case .brakeFluid: .interval(Recurrence(count: 2, unit: .year))
        // Check the battery in mid October, before the cold weather.
        case .batteryCheck: .yearly(month: 10, day: 15)
        // Winter tyres must be on before 1 November, so the last good day is 31 October.
        case .winterTyres: .yearly(month: 10, day: 31)
        // Summer tyres go on "around" 1 April.
        case .summerTyres: .yearly(month: 4, day: 1)
        case .oilService: .distance(intervalKm: 15_000)
        case .washExterior, .cleanInterior: .interval(Recurrence(count: 1, unit: .week))
        case .tyrePressure: .interval(Recurrence(count: 1, unit: .month))
        case .custom: .interval(Recurrence(count: 1, unit: .year))
        }
    }

    /// A small tip shown under the task in the form. Most tasks have none.
    var hint: String? {
        switch self {
        case .tyrePressure: "Quick way: if your car has a connected app, like MyMazda, it can show all four tyres."
        default: nil
        }
    }

    /// The preset with this task name, or nil for anything you named yourself.
    static func preset(named task: String) -> CarTaskPreset? {
        allCases.first { $0 != .custom && $0.taskName == task }
    }
}
