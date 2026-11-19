import Foundation

/// A task that comes round every so many kilometres, such as an oil change every 15,000 km.
///
/// The phone cannot read the odometer, so the owner gives a reading now and then. Between
/// readings the app assumes a steady `kmPerYear` to estimate the odometer and the due date.
nonisolated struct DistanceSchedule: Codable, Hashable {
    /// Kilometres between services.
    var intervalKm: Int
    /// Odometer at the last service.
    var lastServiceKm: Int
    /// The most recent odometer reading the owner gave, and the day they gave it.
    var readingKm: Int
    var readingDate: Date
    /// About how far the car is driven in a year.
    var kmPerYear: Int

    /// The odometer value at which the next service is due.
    var dueAtKm: Int {
        lastServiceKm + intervalKm
    }

    private var kmPerDay: Double {
        Double(max(kmPerYear, 1)) / 365
    }

    /// Estimated odometer on a day, assuming steady driving since the last reading.
    func estimatedKm(on date: Date, calendar: Calendar = .current) -> Int {
        let days = calendar.dateComponents(
            [.day],
            from: calendar.startOfDay(for: readingDate),
            to: calendar.startOfDay(for: date)
        ).day ?? 0
        return readingKm + Int((Double(max(days, 0)) * kmPerDay).rounded())
    }

    /// Estimated kilometres until the service is due. Negative once it is past due.
    func kmLeft(on date: Date, calendar: Calendar = .current) -> Int {
        dueAtKm - estimatedKm(on: date, calendar: calendar)
    }

    /// The estimated day the service becomes due. Past the limit counts as at least one day overdue.
    func dueDate(calendar: Calendar = .current) -> Date {
        let start = calendar.startOfDay(for: readingDate)
        let days = Int((Double(dueAtKm - readingKm) / kmPerDay).rounded(.down))
        return calendar.date(byAdding: .day, value: days, to: start) ?? start
    }

    /// About how many days one service lasts at the usual pace of driving. At least one.
    var daysPerInterval: Int {
        max(Int((Double(intervalKm) / kmPerDay).rounded()), 1)
    }

    /// A reading cannot be lower than the odometer was at the last service.
    func accepts(readingKm km: Int) -> Bool {
        km >= lastServiceKm
    }

    mutating func updateReading(km: Int, on date: Date) {
        readingKm = km
        readingDate = date
    }

    /// Restarts the count. Without a reading it assumes the estimated odometer.
    mutating func recordService(atKm km: Int?, on date: Date, calendar: Calendar = .current) {
        let reading = km ?? estimatedKm(on: date, calendar: calendar)
        lastServiceKm = reading
        updateReading(km: reading, on: date)
    }
}
