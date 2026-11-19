import SwiftUI

/// "Every 7 days", "Every year on 31 October", "Every 15,000 km".
struct ScheduleText: View {
    let schedule: Schedule

    var body: some View {
        switch schedule {
        case .interval(let recurrence):
            RecurrenceText(recurrence: recurrence)
        case .yearly(let month, let day):
            // 2000 is a leap year, so every month and day combination is a real date.
            let date = Calendar.current.date(from: DateComponents(year: 2000, month: month, day: day)) ?? .now
            Text("Every year on \(date, format: .dateTime.day().month(.wide))")
        case .distance(let distance):
            Text("Every \(distance.intervalKm, format: .number) km")
        }
    }
}
