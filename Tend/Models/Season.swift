import Foundation

/// The part of the year, for plants that drink differently through it. Northern hemisphere only.
nonisolated enum Season: CaseIterable {
    /// April to September.
    case growing
    /// March and October.
    case shoulder
    /// November to February.
    case rest

    static func of(_ date: Date, calendar: Calendar = .current) -> Season {
        switch calendar.component(.month, from: date) {
        case 4...9: .growing
        case 3, 10: .shoulder
        default: .rest
        }
    }

    /// The word used in sentences.
    var name: String {
        switch self {
        case .growing: String(localized: "summer")
        case .shoulder: String(localized: "spring or autumn")
        case .rest: String(localized: "winter")
        }
    }
}

/// Days between waterings in each season.
nonisolated struct SeasonalWatering: Hashable {
    let growing: Int
    let shoulder: Int
    let rest: Int

    func days(in season: Season) -> Int {
        switch season {
        case .growing: growing
        case .shoulder: shoulder
        case .rest: rest
        }
    }

    func days(on date: Date, calendar: Calendar = .current) -> Int {
        days(in: Season.of(date, calendar: calendar))
    }

    var summary: String {
        String(localized: "Days between waterings: summer \(growing), spring or autumn \(shoulder), winter \(rest).")
    }
}
