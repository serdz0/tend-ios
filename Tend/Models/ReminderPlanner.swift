import Foundation

/// Works out which reminders the phone should hold: one per item, on its due day at its reminder time.
/// Past times get none, and the list stays under the system limit of 64 pending notifications.
enum ReminderPlanner {
    static let maxPending = 60

    static func plan(for item: CareItem, now: Date = .now, calendar: Calendar = .current) -> ReminderPlan? {
        let day = calendar.startOfDay(for: item.dueDate)
        let fire = item.reminderTime.date(on: day, calendar: calendar)
        guard fire > now else { return nil }

        return ReminderPlan(
            identifier: "care-\(item.id.uuidString)",
            itemID: item.id,
            fireDate: fire,
            title: item.title,
            body: body(for: item),
            needsOdometer: item.distance != nil
        )
    }

    /// Soonest first, at most `maxPending`.
    static func plans(for items: [CareItem], now: Date = .now, calendar: Calendar = .current) -> [ReminderPlan] {
        let plans = items.compactMap { plan(for: $0, now: now, calendar: calendar) }
        return Array(plans.sorted { $0.fireDate < $1.fireDate }.prefix(maxPending))
    }

    private static func body(for item: CareItem) -> String {
        switch item.kind {
        case .plant:
            "Your \(item.name) would love a drink today."
        case .car where item.distance != nil:
            "\(item.task) is due around now. Got a fresh odometer reading?"
        case .car:
            "\(item.task) is due today. A quick tick and you're set."
        }
    }
}
