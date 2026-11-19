import Foundation

/// All the history entries from one day, for the History tab.
struct HistoryDay: Identifiable {
    let day: Date
    /// Newest first.
    let events: [CareEvent]

    var id: Date { day }

    /// Groups entries by day. The newest day comes first.
    static func groups(from events: [CareEvent], calendar: Calendar = .current) -> [HistoryDay] {
        let byDay = Dictionary(grouping: events) { calendar.startOfDay(for: $0.date) }
        return byDay
            .map { day, events in HistoryDay(day: day, events: events.sorted { $0.date > $1.date }) }
            .sorted { $0.day > $1.day }
    }
}
