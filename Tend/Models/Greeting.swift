import Foundation

/// The friendly hello at the top of the Today screen.
enum Greeting {
    static func text(at date: Date, calendar: Calendar = .current) -> String {
        switch DayPeriod.of(date, calendar: calendar) {
        case .morning: "Good morning"
        case .afternoon: "Good afternoon"
        case .evening: "Good evening"
        case .night: "Hello, night owl"
        }
    }
}
