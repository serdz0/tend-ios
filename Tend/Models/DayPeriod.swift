import Foundation

/// The part of the day. Drives the greeting and the colour of the sky behind it.
enum DayPeriod: CaseIterable {
    case morning, afternoon, evening, night

    static func of(_ date: Date, calendar: Calendar = .current) -> DayPeriod {
        switch calendar.component(.hour, from: date) {
        case 5..<12: .morning
        case 12..<18: .afternoon
        case 18..<22: .evening
        default: .night
        }
    }
}
