import SwiftUI

/// What is on one day. Each line opens the item.
struct CalendarDaySection: View {
    let day: Date
    let entries: [CalendarEntry]
    let now: Date

    var body: some View {
        Section {
            if entries.isEmpty {
                Text("A quiet day. Nothing planned.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(entries) { entry in
                    NavigationLink(value: entry.item) {
                        CalendarEntryRow(entry: entry, now: now)
                    }
                }
            }
        } header: {
            Text(day, format: .dateTime.weekday(.wide).day().month(.wide))
                .textCase(nil)
        }
        .listRowBackground(Theme.card)
    }
}
