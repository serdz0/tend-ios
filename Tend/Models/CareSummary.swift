import Foundation

/// A quick count of what needs doing, and one warm sentence that says it.
struct CareSummary {
    let overdue: Int
    let today: Int
    /// Due from tomorrow up to a week ahead.
    let thisWeek: Int
    /// True when there are no items at all, so "all caught up" would not be true, just empty.
    let hasNothingYet: Bool

    init(items: [CareItem], now: Date = .now, calendar: Calendar = .current) {
        var overdue = 0
        var today = 0
        var thisWeek = 0
        for item in items {
            switch item.status(now: now, calendar: calendar) {
            case .overdue: overdue += 1
            case .dueToday: today += 1
            case .upcoming(let days) where days <= 7: thisWeek += 1
            case .upcoming: break
            }
        }
        self.overdue = overdue
        self.today = today
        self.thisWeek = thisWeek
        self.hasNothingYet = items.isEmpty
    }

    /// Overdue plus due today: what is waiting right now.
    var needsAttention: Int {
        overdue + today
    }

    var headline: String {
        if hasNothingYet {
            return String(localized: "Welcome to Tend. Let's add your first thing.")
        }
        return switch (needsAttention, thisWeek) {
        case (0, 0):
            String(localized: "Nothing needs you this week. Enjoy the calm.")
        case (0, let week):
            String(localized: "You're all caught up. \(week) things are coming this week.")
        case (let count, _):
            String(localized: "\(count) things need you today.")
        }
    }
}
