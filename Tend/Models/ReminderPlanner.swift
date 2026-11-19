import Foundation

/// Works out which reminders the phone should hold.
///
/// - Morning note (the default): one note a day for the next three days, listing what is waiting.
///   It only looks three days ahead on purpose: if you stop opening Tend, it goes quiet by itself
///   instead of nagging. Opening the app brings it back.
/// - A note for each thing: one reminder per item, on its due day at its own time.
///
/// Quiet days silence both. Past times get nothing, and the list stays under the system limit of 64.
enum ReminderPlanner {
    static let maxPending = 60
    /// How many mornings the digest looks ahead.
    static let digestDays = 3

    static func plans(
        for items: [CareItem],
        settings: ReminderSettings,
        now: Date = .now,
        calendar: Calendar = .current
    ) -> [ReminderPlan] {
        switch settings.style {
        case .digest:
            digestPlans(for: items, settings: settings, now: now, calendar: calendar)
        case .perItem:
            perItemPlans(for: items, settings: settings, now: now, calendar: calendar)
        }
    }

    // MARK: One note for each thing

    static func plan(for item: CareItem, now: Date = .now, calendar: Calendar = .current) -> ReminderPlan? {
        let day = calendar.startOfDay(for: item.dueDate)
        let fire = item.reminderTime.date(on: day, calendar: calendar)
        guard fire > now else { return nil }

        return ReminderPlan(
            identifier: "care-\(item.id.uuidString)",
            itemID: item.id,
            fireDate: fire,
            title: item.title,
            body: body(for: item, variant: dayOfYear(day, calendar: calendar)),
            needsOdometer: item.distance != nil
        )
    }

    /// Soonest first, at most `maxPending`.
    static func plans(for items: [CareItem], now: Date = .now, calendar: Calendar = .current) -> [ReminderPlan] {
        perItemPlans(for: items, settings: ReminderSettings(), now: now, calendar: calendar)
    }

    private static func perItemPlans(
        for items: [CareItem], settings: ReminderSettings, now: Date, calendar: Calendar
    ) -> [ReminderPlan] {
        let plans = items
            .compactMap { plan(for: $0, now: now, calendar: calendar) }
            .filter { !settings.isQuiet(on: $0.fireDate, calendar: calendar) }
        return Array(plans.sorted { $0.fireDate < $1.fireDate }.prefix(maxPending))
    }

    private static func body(for item: CareItem, variant: Int) -> String {
        switch item.kind {
        case .plant:
            [
                String(localized: "Your \(item.name) would love a drink today."),
                String(localized: "\(item.name) is a little thirsty. A quick drink and you're done."),
                String(localized: "A small one for today: water your \(item.name)."),
            ][variant % 3]
        case .car where item.distance != nil:
            [
                String(localized: "\(item.displayTask) is due around now. Got a fresh odometer reading?"),
                String(localized: "\(item.displayTask) is coming up about now. A quick odometer check helps."),
            ][variant % 2]
        case .car:
            [
                String(localized: "\(item.displayTask) is due today. A quick tick and you're set."),
                String(localized: "\(item.displayTask) is on today's list. Whenever suits you."),
            ][variant % 2]
        }
    }

    // MARK: One note each morning

    private static func digestPlans(
        for items: [CareItem], settings: ReminderSettings, now: Date, calendar: Calendar
    ) -> [ReminderPlan] {
        let today = calendar.startOfDay(for: now)
        var plans: [ReminderPlan] = []
        var mornings = 0
        var offset = 0

        // Quiet days and mornings already gone do not count, so a break never uses up the three days.
        while mornings < digestDays, offset < 60 {
            let day = calendar.date(byAdding: .day, value: offset, to: today) ?? today
            offset += 1
            let fire = settings.digestTime.date(on: day, calendar: calendar)
            guard fire > now, !settings.isQuiet(on: day, calendar: calendar) else { continue }
            mornings += 1

            let waiting = items
                .filter { item in
                    let due = calendar.startOfDay(for: item.dueDate)
                    // A routine chore is mentioned only on its own day, never carried over.
                    return item.isRoutine ? due == day : due <= day
                }
                .sorted { $0.dueDate < $1.dueDate }
            guard !waiting.isEmpty else { continue }

            plans.append(ReminderPlan(
                identifier: "care-digest-\(dayStamp(day, calendar: calendar))",
                itemID: nil,
                fireDate: fire,
                title: Greeting.text(at: fire, calendar: calendar),
                body: digestBody(titles: waiting.map(\.title), variant: dayOfYear(day, calendar: calendar)),
                needsOdometer: false
            ))
        }
        return plans
    }

    /// "3 things are waiting for you: A, B and C." The wording rotates so it never goes stale.
    static func digestBody(titles: [String], variant: Int) -> String {
        let count = titles.count
        let list: String
        switch count {
        case 0, 1: list = titles.first ?? ""
        case 2: list = String(localized: "\(titles[0]) and \(titles[1])")
        case 3: list = String(localized: "\(titles[0]), \(titles[1]) and \(titles[2])")
        default: list = String(localized: "\(titles[0]), \(titles[1]), \(titles[2]) and \(count - 3) more")
        }

        switch variant % 3 {
        case 0:
            return String(localized: "\(count) things are waiting for you: \(list).")
        case 1:
            return String(localized: "A small list for today: \(list).")
        default:
            return String(localized: "A gentle heads-up: \(list). One at a time is plenty.")
        }
    }

    private static func dayOfYear(_ day: Date, calendar: Calendar) -> Int {
        calendar.ordinality(of: .day, in: .year, for: day) ?? 0
    }

    private static func dayStamp(_ day: Date, calendar: Calendar) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: day)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }
}
