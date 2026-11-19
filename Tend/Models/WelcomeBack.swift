import Foundation

/// A calm hello after a few days away: what is waiting, and one easy place to start.
/// Never scolds, never counts days. It only exists when you have been away and something is waiting.
struct WelcomeBack {
    /// Days away before the hello appears.
    static let daysAwayNeeded = 3

    let waiting: Int
    /// A small first step: a plant if there is one, otherwise whatever has waited longest.
    let firstStep: CareItem

    init?(lastActive: Date?, items: [CareItem], now: Date = .now, calendar: Calendar = .current) {
        guard let lastActive else { return nil }
        let daysAway = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: lastActive),
            to: calendar.startOfDay(for: now)
        ).day ?? 0
        guard daysAway >= Self.daysAwayNeeded else { return nil }

        let needing = items
            .filter { item in
                switch item.status(now: now, calendar: calendar) {
                case .overdue, .dueToday: true
                case .upcoming: false
                }
            }
            .sorted { $0.dueDate < $1.dueDate }
        guard let first = needing.first(where: { $0.kind == .plant }) ?? needing.first else { return nil }

        self.waiting = needing.count
        self.firstStep = first
    }

    var title: String { "Welcome back" }

    var message: String {
        let count = waiting == 1 ? "1 thing is" : "\(waiting) things are"
        return "\(count) waiting. Nothing is wrong, and there's no rush."
    }

    var suggestion: String {
        "A small place to start: \(firstStep.title)."
    }
}
