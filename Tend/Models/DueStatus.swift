import Foundation

/// Where an item stands compared with today.
nonisolated enum DueStatus: Equatable {
    case overdue(days: Int)
    case dueToday
    case upcoming(days: Int)

    var isOverdue: Bool {
        if case .overdue = self { true } else { false }
    }
}
