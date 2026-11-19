import Foundation

/// How a car preset repeats, before the owner has given any dates or mileage.
nonisolated enum ScheduleStyle: Equatable {
    /// Every so many days, months or years.
    case interval(Recurrence)
    /// On the same calendar date every year.
    case yearly(month: Int, day: Int)
    /// Every so many kilometres.
    case distance(intervalKm: Int)
}
