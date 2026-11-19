import Foundation

nonisolated enum RecurrenceUnit: String, Codable, CaseIterable, Identifiable {
    case day
    case week
    case month
    case year

    var id: Self { self }

    /// For the unit picker.
    var pluralName: String {
        switch self {
        case .day: "Days"
        case .week: "Weeks"
        case .month: "Months"
        case .year: "Years"
        }
    }

    var calendarComponent: Calendar.Component {
        switch self {
        case .day: .day
        case .week: .weekOfYear
        case .month: .month
        case .year: .year
        }
    }
}

/// "Every 7 days", "every 6 months".
nonisolated struct Recurrence: Codable, Hashable {
    var count: Int
    var unit: RecurrenceUnit

    /// The date this task comes round again, counted from `date`.
    func next(after date: Date, calendar: Calendar = .current) -> Date {
        calendar.date(byAdding: unit.calendarComponent, value: count, to: date) ?? date
    }
}
