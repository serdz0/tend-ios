import Foundation

/// How the sprout mascot feels about today. It is never sad and never scolds: a big pile
/// only makes it encouraging.
struct DayMood: Equatable {
    enum Kind: Equatable {
        /// Everything is done, and something was finished today.
        case celebrating
        /// Nothing is waiting.
        case resting
        /// One or two things are waiting.
        case cheerful
        /// Three or more are waiting.
        case encouraging
    }

    let kind: Kind

    init(items: [CareItem], now: Date = .now, calendar: Calendar = .current) {
        guard !items.isEmpty else {
            kind = .cheerful
            return
        }
        var waiting = 0
        var finishedToday = false
        for item in items {
            switch item.status(now: now, calendar: calendar) {
            case .overdue, .dueToday: waiting += 1
            case .upcoming: break
            }
            if item.events.contains(where: { $0.kind == .done && calendar.isDate($0.date, inSameDayAs: now) }) {
                finishedToday = true
            }
        }
        switch waiting {
        case 0: kind = finishedToday ? .celebrating : .resting
        case 1...2: kind = .cheerful
        default: kind = .encouraging
        }
    }

    /// One sentence for VoiceOver, so the picture is not a mystery to people who cannot see it.
    var sentence: String {
        Self.sentence(for: kind)
    }

    static func sentence(for kind: Kind) -> String {
        switch kind {
        case .celebrating: "Sprout is cheering. Everything is done."
        case .resting: "Sprout is relaxing in the sun."
        case .cheerful: "Sprout is smiling."
        case .encouraging: "Sprout is waving you on."
        }
    }
}
