import Foundation

/// A time on the clock, such as 10:30. Used for the daily reminder.
nonisolated struct TimeOfDay: Codable, Hashable {
    var hour: Int
    var minute: Int

    static let defaultReminder = TimeOfDay(hour: 10, minute: 30)

    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }

    init(date: Date, calendar: Calendar = .current) {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        self.init(hour: parts.hour ?? Self.defaultReminder.hour, minute: parts.minute ?? Self.defaultReminder.minute)
    }

    /// This time on the given day, for a time picker or a notification.
    func date(on day: Date, calendar: Calendar = .current) -> Date {
        calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
    }
}
