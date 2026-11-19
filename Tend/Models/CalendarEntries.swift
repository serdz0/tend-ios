import Foundation

/// Everything the calendar shows between two days: what is due, what is expected later,
/// and what has been done or snoozed.
///
/// Expected entries are a projection. They assume each task is done on its due day, so a
/// weekly watering shows every seven days after the next one. An overdue task is projected from
/// today, because that is when it can be done.
struct CalendarEntries {
    private let byDay: [Date: [CalendarEntry]]
    private let calendar: Calendar

    init(items: [CareItem], from start: Date, through end: Date, now: Date = .now, calendar: Calendar = .current) {
        let first = calendar.startOfDay(for: start)
        let last = calendar.startOfDay(for: end)
        let today = calendar.startOfDay(for: now)
        var byDay: [Date: [CalendarEntry]] = [:]

        func add(_ entry: CalendarEntry, on day: Date) {
            guard day >= first, day <= last else { return }
            byDay[day, default: []].append(entry)
        }

        for item in items {
            let due = calendar.startOfDay(for: item.dueDate)
            add(CalendarEntry(item: item, kind: .due, date: due), on: due)

            var current = max(due, today)
            for _ in 0..<1_000 {
                let next = Self.next(after: current, for: item, calendar: calendar)
                guard next > current, next <= last else { break }
                add(CalendarEntry(item: item, kind: .expected, date: next), on: next)
                current = next
            }

            for event in item.events {
                let kind: CalendarEntry.Kind = event.kind == .done ? .done : .snoozed
                add(CalendarEntry(item: item, kind: kind, date: event.date),
                    on: calendar.startOfDay(for: event.date))
            }
        }

        self.byDay = byDay.mapValues { entries in
            entries.sorted {
                if $0.kind != $1.kind { return $0.kind.rawValue < $1.kind.rawValue }
                if $0.kind == .done || $0.kind == .snoozed { return $0.date < $1.date }
                return $0.item.title.localizedStandardCompare($1.item.title) == .orderedAscending
            }
        }
        self.calendar = calendar
    }

    /// What is on one day: due first, then expected, then done and snoozed.
    func entries(on day: Date) -> [CalendarEntry] {
        byDay[calendar.startOfDay(for: day)] ?? []
    }

    /// The groups on a day, for the coloured dots. Each group appears once.
    func categories(on day: Date) -> [CareCategory] {
        let present = Set(entries(on: day).map(\.category))
        return CareCategory.allCases.filter(present.contains)
    }

    /// The day after `date` that the item would come round again.
    private static func next(after date: Date, for item: CareItem, calendar: Calendar) -> Date {
        switch item.schedule {
        case .interval(let stored):
            calendar.startOfDay(for: (item.recurrence(on: date, calendar: calendar) ?? stored).next(after: date, calendar: calendar))
        case .yearly(let month, let day):
            Schedule.nextOccurrence(month: month, day: day, after: date, calendar: calendar)
        case .distance(let distance):
            calendar.date(byAdding: .day, value: distance.daysPerInterval, to: date) ?? date
        }
    }
}
