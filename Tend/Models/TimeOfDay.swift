import Foundation

/// A time on the clock, such as 09:00. Used for the daily reminder.
nonisolated struct TimeOfDay: Codable, Hashable {
    var hour: Int
    var minute: Int

    static let defaultReminder = TimeOfDay(hour: 9, minute: 0)

    init(hour: Int, minute: Int) {
        self.hour = hour
        self.minute = minute
    }

    init(date: Date, calendar: Calendar = .current) {
        let parts = calendar.dateComponents([.hour, .minute], from: date)
        self.init(hour: parts.hour ?? 9, minute: parts.minute ?? 0)
    }

    /// This time on the given day, for a time picker or a notification.
    func date(on day: Date, calendar: Calendar = .current) -> Date {
        calendar.date(bySettingHour: hour, minute: minute, second: 0, of: day) ?? day
    }
}
