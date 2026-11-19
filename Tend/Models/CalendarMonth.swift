import Foundation

/// The grid for one month: days in order, with blanks so the first day lands under the right weekday.
struct CalendarMonth {
    /// Midnight on the first of the month.
    let start: Date
    /// Whole weeks of days. `nil` is a blank before the first or after the last day.
    let cells: [Date?]
    /// Short weekday names starting on the calendar's first weekday.
    let weekdaySymbols: [String]
    private let calendar: Calendar

    init(containing date: Date, calendar: Calendar = .current) {
        let first = calendar.date(from: calendar.dateComponents([.year, .month], from: date)) ?? date
        let dayCount = calendar.range(of: .day, in: .month, for: first)?.count ?? 30
        let weekday = calendar.component(.weekday, from: first)
        let blanks = (weekday - calendar.firstWeekday + 7) % 7

        var cells: [Date?] = Array(repeating: nil, count: blanks)
        for offset in 0..<dayCount {
            cells.append(calendar.date(byAdding: .day, value: offset, to: first))
        }
        while cells.count % 7 != 0 {
            cells.append(nil)
        }

        let symbols = calendar.shortWeekdaySymbols
        let shift = calendar.firstWeekday - 1
        self.start = first
        self.cells = cells
        self.weekdaySymbols = Array(symbols[shift...] + symbols[..<shift])
        self.calendar = calendar
    }

    func shifted(by months: Int) -> CalendarMonth {
        let moved = calendar.date(byAdding: .month, value: months, to: start) ?? start
        return CalendarMonth(containing: moved, calendar: calendar)
    }

    func contains(_ date: Date) -> Bool {
        calendar.isDate(date, equalTo: start, toGranularity: .month)
    }
}
