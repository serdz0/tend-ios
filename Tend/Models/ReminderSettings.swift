import Foundation

/// How Tend reaches you: one note each morning, or a note for each thing.
nonisolated enum ReminderStyle: String, Codable, Hashable, CaseIterable {
    /// One note a day listing what is waiting. The calm default.
    case digest
    /// A reminder on each item's own due day and time.
    case perItem
}

/// Everything you can change about how Tend talks to you. Kept small on purpose.
nonisolated struct ReminderSettings: Codable, Hashable {
    var style: ReminderStyle = .digest
    /// When the morning note arrives.
    var digestTime: TimeOfDay = .defaultReminder
    /// The first day reminders come back after a quiet break. Nil when there is no break.
    var pausedUntil: Date?
    /// Whether Today gently asks after the same thing has been snoozed three times in a row.
    var snoozeCheckIn = true

    /// A quiet break of this many days, counting today. One day means "back tomorrow".
    mutating func pause(forDays days: Int, from now: Date, calendar: Calendar = .current) {
        let today = calendar.startOfDay(for: now)
        pausedUntil = calendar.date(byAdding: .day, value: days, to: today)
    }

    mutating func resume() {
        pausedUntil = nil
    }

    /// True when the day falls inside a quiet break.
    func isQuiet(on date: Date, calendar: Calendar = .current) -> Bool {
        guard let pausedUntil else { return false }
        return calendar.startOfDay(for: date) < pausedUntil
    }

    /// The day the break ends, or nil when there is no break right now.
    func activePause(now: Date, calendar: Calendar = .current) -> Date? {
        isQuiet(on: now, calendar: calendar) ? pausedUntil : nil
    }

    /// One plain line for the Today screen.
    var summary: String {
        switch style {
        case .digest:
            let minute = digestTime.minute < 10 ? "0\(digestTime.minute)" : "\(digestTime.minute)"
            return "One note each morning at \(digestTime.hour):\(minute)"
        case .perItem:
            return "A note for each thing"
        }
    }
}
