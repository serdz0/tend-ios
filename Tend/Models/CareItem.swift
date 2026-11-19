import Foundation
import SwiftData

/// A plant or a car task that comes round again and again.
@Model
final class CareItem {
    var id: UUID
    var name: String
    var kind: ItemKind
    var task: String
    var schedule: Schedule
    /// The day this is next due.
    var dueDate: Date
    /// Set for plants, so the detail screen can say what sort of plant it is.
    var plantType: PlantType?
    /// What time of day the reminder arrives.
    var reminderTime: TimeOfDay = TimeOfDay.defaultReminder
    @Relationship(deleteRule: .cascade, inverse: \CareEvent.item)
    var events: [CareEvent] = []

    init(
        name: String,
        kind: ItemKind,
        task: String,
        schedule: Schedule,
        dueDate: Date,
        plantType: PlantType? = nil,
        reminderTime: TimeOfDay = .defaultReminder
    ) {
        self.id = UUID()
        self.name = name
        self.kind = kind
        self.task = task
        self.schedule = schedule
        self.dueDate = dueDate
        self.plantType = plantType
        self.reminderTime = reminderTime
    }

    /// An item that repeats every so many days, weeks, months or years.
    convenience init(name: String, kind: ItemKind, task: String, recurrence: Recurrence, dueDate: Date) {
        self.init(name: name, kind: kind, task: task, schedule: .interval(recurrence), dueDate: dueDate)
    }

    /// "Water Monstera" for a plant, "STK inspection" for a car task.
    var title: String {
        switch kind {
        case .plant: "\(task) \(name)"
        case .car: task
        }
    }

    /// The mileage details, for items that repeat by distance.
    var distance: DistanceSchedule? {
        if case .distance(let distance) = schedule { distance } else { nil }
    }

    /// Washing, cleaning and checking tyre pressure. These never count as overdue:
    /// a missed one is simply there to do whenever you are ready.
    var isRoutine: Bool {
        kind == .car && CarTaskGroup.routine.presets.contains { $0.taskName == task }
    }

    func status(now: Date = .now, calendar: Calendar = .current) -> DueStatus {
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: now),
            to: calendar.startOfDay(for: dueDate)
        ).day ?? 0
        if days < 0 { return isRoutine ? .dueToday : .overdue(days: -days) }
        if days == 0 { return .dueToday }
        return .upcoming(days: days)
    }

    /// Marks it done and works out the next due date.
    ///
    /// - Every so many days or months: counts from today, not from the old due date, so a plant
    ///   watered late is not due again the next day.
    /// - A fixed date each year: the same date next year, however early or late it was done.
    /// - By distance: restarts the count from the odometer reading (or the estimate if none is given).
    ///
    /// Returns a way to take it back.
    @discardableResult
    func markDone(now: Date = .now, odometerKm: Int? = nil, calendar: Calendar = .current) -> CareUndo {
        let event = CareEvent(date: now, kind: .done)
        let restore = CareUndo.Restore(item: self, dueDate: dueDate, schedule: schedule, event: event)
        events.append(event)
        let today = calendar.startOfDay(for: now)

        switch schedule {
        case .interval(let recurrence):
            dueDate = recurrence.next(after: today, calendar: calendar)
        case .yearly(let month, let day):
            let served = max(today, calendar.startOfDay(for: dueDate))
            dueDate = Schedule.nextOccurrence(month: month, day: day, after: served, calendar: calendar)
        case .distance(var distance):
            distance.recordService(atKm: odometerKm, on: now, calendar: calendar)
            schedule = .distance(distance)
            dueDate = distance.dueDate(calendar: calendar)
        }
        return CareUndo(message: "\(title) is done.", restores: [restore])
    }

    /// Pushes it back one day: to tomorrow if it is due or overdue, otherwise one day later than planned.
    /// Returns a way to take it back.
    @discardableResult
    func snooze(now: Date = .now, calendar: Calendar = .current) -> CareUndo {
        let event = CareEvent(date: now, kind: .snoozed)
        let restore = CareUndo.Restore(item: self, dueDate: dueDate, schedule: schedule, event: event)
        events.append(event)
        let base = max(calendar.startOfDay(for: now), calendar.startOfDay(for: dueDate))
        dueDate = calendar.date(byAdding: .day, value: 1, to: base) ?? base
        return CareUndo(message: "\(title) is snoozed for a day.", restores: [restore])
    }

    /// How many times in a row it has been snoozed, counting back from the latest entry. Done starts it again.
    var snoozeStreak: Int {
        events.sorted { $0.date > $1.date }.prefix { $0.kind == .snoozed }.count
    }

    /// True after the third snooze in a row, and again after the sixth: a good moment to ask if the schedule fits.
    var needsSnoozeCheckIn: Bool {
        let streak = snoozeStreak
        return streak > 0 && streak % 3 == 0
    }

    /// Records a new odometer reading and re-estimates the due date. Does nothing for other schedules.
    func updateMileage(km: Int, now: Date = .now, calendar: Calendar = .current) {
        guard case .distance(var distance) = schedule else { return }
        distance.updateReading(km: km, on: now)
        schedule = .distance(distance)
        dueDate = distance.dueDate(calendar: calendar)
    }
}
