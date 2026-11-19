import Foundation

/// The friendly hello at the top of the Today screen.
enum Greeting {
    static func text(at date: Date, calendar: Calendar = .current) -> String {
        switch DayPeriod.of(date, calendar: calendar) {
        case .morning: String(localized: "Good morning")
        case .afternoon: String(localized: "Good afternoon")
        case .evening: String(localized: "Good evening")
        case .night: String(localized: "Hello, night owl")
        }
    }
}
