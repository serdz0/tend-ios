import Foundation

/// How an item comes round again.
nonisolated enum Schedule: Codable, Hashable {
    /// Every so many days, weeks, months or years, counted from the day it was done.
    case interval(Recurrence)
    /// On the same calendar date every year, whenever it was done (tyre swaps).
    case yearly(month: Int, day: Int)
    /// Every so many kilometres (oil service).
    case distance(DistanceSchedule)

    /// The first day after `date` that falls on the given month and day.
    static func nextOccurrence(month: Int, day: Int, after date: Date, calendar: Calendar = .current) -> Date {
        let start = calendar.startOfDay(for: date)
        let match = calendar.nextDate(
            after: start,
            matching: DateComponents(month: month, day: day),
            matchingPolicy: .nextTime
        )
        return calendar.startOfDay(for: match ?? start)
    }
}
