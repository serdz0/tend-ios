import Foundation

/// A quick count of what needs doing, and one warm sentence that says it.
struct CareSummary {
    let overdue: Int
    let today: Int
    /// Due from tomorrow up to a week ahead.
    let thisWeek: Int

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
    }

    /// Overdue plus due today: what is waiting right now.
    var needsAttention: Int {
        overdue + today
    }

    var headline: String {
        switch (needsAttention, thisWeek) {
        case (0, 0):
            "Nothing needs you this week. Enjoy the calm."
        case (0, 1):
            "You're all caught up. One small thing is coming this week."
        case (0, let week):
            "You're all caught up. \(week) things are coming this week."
        case (1, _):
            "One little thing needs you today."
        case (let count, _):
            "\(count) things need you today."
        }
    }
}
