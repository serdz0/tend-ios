import Foundation

/// Picks the one thing to begin with when several are waiting, so there is no choosing to do.
/// The thing waiting longest goes first. Tasks that need the odometer come last, because
/// a quick tap is an easier way to start.
enum StartHere {
    /// Nil when fewer than two things are waiting: with one thing there is nothing to choose.
    static func pick(from items: [CareItem], now: Date = .now, calendar: Calendar = .current) -> CareItem? {
        let waiting = items.filter {
            switch $0.status(now: now, calendar: calendar) {
            case .overdue, .dueToday: true
            case .upcoming: false
            }
        }
        guard waiting.count >= 2 else { return nil }

        let quick = waiting.filter { $0.distance == nil }
        let pool = quick.isEmpty ? waiting : quick
        return pool.min { lhs, rhs in
            if lhs.dueDate != rhs.dueDate { return lhs.dueDate < rhs.dueDate }
            return lhs.title.localizedStandardCompare(rhs.title) == .orderedAscending
        }
    }
}
