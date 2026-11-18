import Foundation

/// Splits items into the three groups on the Today screen.
struct TodaySections {
    /// How far ahead "Coming up" looks.
    static let comingUpDays = 30

    let overdue: [CareItem]
    let today: [CareItem]
    let comingUp: [CareItem]

    init(items: [CareItem], now: Date = .now, calendar: Calendar = .current) {
        var overdue: [CareItem] = []
        var today: [CareItem] = []
        var comingUp: [CareItem] = []

        for item in items {
            switch item.status(now: now, calendar: calendar) {
            case .overdue:
                overdue.append(item)
            case .dueToday:
                today.append(item)
            case .upcoming(let days) where days <= Self.comingUpDays:
                comingUp.append(item)
            case .upcoming:
                break
            }
        }

        self.overdue = overdue.sorted { $0.dueDate < $1.dueDate }
        self.today = today.sorted { $0.title.localizedStandardCompare($1.title) == .orderedAscending }
        self.comingUp = comingUp.sorted { $0.dueDate < $1.dueDate }
    }

    /// True when something needs doing now (overdue or due today).
    var hasWork: Bool {
        !overdue.isEmpty || !today.isEmpty
    }
}
