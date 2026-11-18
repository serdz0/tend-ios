import Foundation
import SwiftData

/// A plant or a car task that comes round again and again.
@Model
final class CareItem {
    var id: UUID
    var name: String
    var kind: ItemKind
    var task: String
    var recurrence: Recurrence
    /// The day this is next due.
    var dueDate: Date
    @Relationship(deleteRule: .cascade, inverse: \CareEvent.item)
    var events: [CareEvent] = []

    init(name: String, kind: ItemKind, task: String, recurrence: Recurrence, dueDate: Date) {
        self.id = UUID()
        self.name = name
        self.kind = kind
        self.task = task
        self.recurrence = recurrence
        self.dueDate = dueDate
    }

    /// "Water Monstera" for a plant, "STK inspection" for a car task.
    var title: String {
        switch kind {
        case .plant: "\(task) \(name)"
        case .car: task
        }
    }

    func status(now: Date = .now, calendar: Calendar = .current) -> DueStatus {
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: now),
            to: calendar.startOfDay(for: dueDate)
        ).day ?? 0
        if days < 0 { return .overdue(days: -days) }
        if days == 0 { return .dueToday }
        return .upcoming(days: days)
    }

    /// Marks it done. The next due date counts from today, not from the old due date,
    /// so a plant watered late is not due again the next day.
    func markDone(now: Date = .now, calendar: Calendar = .current) {
        events.append(CareEvent(date: now, kind: .done))
        dueDate = recurrence.next(after: calendar.startOfDay(for: now), calendar: calendar)
    }

    /// Pushes it to tomorrow.
    func snooze(now: Date = .now, calendar: Calendar = .current) {
        events.append(CareEvent(date: now, kind: .snoozed))
        let today = calendar.startOfDay(for: now)
        dueDate = calendar.date(byAdding: .day, value: 1, to: today) ?? today
    }
}
