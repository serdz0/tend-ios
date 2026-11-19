import Foundation

/// A kind way to deal with a pile of overdue things: spread them over the next few days.
///
/// At most `perDay` things land on any one day, the most overdue first. Only plants are moved.
/// Car tasks, such as an inspection or an insurance renewal, have real deadlines, so they stay as they are.
struct FreshStart {
    struct Move {
        let item: CareItem
        let newDate: Date
    }

    static let perDay = 2
    /// Below this many things a fresh start is not worth offering.
    static let offerThreshold = 3

    let moves: [Move]
    private let calendar: Calendar

    init(items: [CareItem], now: Date = .now, calendar: Calendar = .current) {
        self.calendar = calendar
        let today = calendar.startOfDay(for: now)

        let movable = items
            .filter { item in
                guard item.kind == .plant, case .interval = item.schedule else { return false }
                return item.status(now: now, calendar: calendar).isOverdue
            }
            .sorted { $0.dueDate < $1.dueDate }

        // How many things already sit on each day, not counting the ones about to move.
        var load: [Date: Int] = [:]
        for item in items where !movable.contains(where: { $0 === item }) {
            load[calendar.startOfDay(for: item.dueDate), default: 0] += 1
        }

        var moves: [Move] = []
        var offset = 0
        for item in movable {
            var day = calendar.date(byAdding: .day, value: offset, to: today) ?? today
            while load[day, default: 0] >= Self.perDay {
                offset += 1
                day = calendar.date(byAdding: .day, value: offset, to: today) ?? today
            }
            load[day, default: 0] += 1
            moves.append(Move(item: item, newDate: day))
        }
        self.moves = moves
    }

    var isWorthOffering: Bool {
        moves.count >= Self.offerThreshold
    }

    /// Moves everything and returns the way back.
    @discardableResult
    func apply() -> CareUndo {
        let restores = moves.map {
            CareUndo.Restore(item: $0.item, dueDate: $0.item.dueDate, schedule: $0.item.schedule, event: nil)
        }
        for move in moves {
            move.item.dueDate = move.newDate
        }
        let days = Set(moves.map(\.newDate)).count
        let plants = moves.count == 1 ? "1 plant" : "\(moves.count) plants"
        let span = days == 1 ? "1 day" : "\(days) days"
        return CareUndo(message: "Spread \(plants) over \(span).", restores: restores)
    }
}
