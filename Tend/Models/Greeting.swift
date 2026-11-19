import Foundation

/// The friendly hello at the top of the Today screen.
enum Greeting {
    static func text(at date: Date, calendar: Calendar = .current) -> String {
        switch calendar.component(.hour, from: date) {
        case 5..<12: "Good morning"
        case 12..<18: "Good afternoon"
        case 18..<22: "Good evening"
        default: "Hello, night owl"
        }
    }
}
