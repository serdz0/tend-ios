import SwiftData
import SwiftUI

/// Everything marked done or snoozed, newest day first.
struct HistoryView: View {
    @Query(sort: \CareEvent.date, order: .reverse) private var events: [CareEvent]

    var body: some View {
        let days = HistoryDay.groups(from: events)

        NavigationStack {
            List {
                HistoryHeader()
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                if days.isEmpty {
                    ContentUnavailableView(
                        "No history yet",
                        systemImage: "clock.arrow.circlepath",
                        description: Text("Things you mark done or snooze will appear here.")
                    )
                    .listRowBackground(Color.clear)
                }

                ForEach(days) { day in
                    Section {
                        ForEach(day.events) { event in
                            HistoryEventRow(event: event)
                                .listRowBackground(Theme.card)
                        }
                    } header: {
                        Text(day.day, format: .dateTime.weekday(.wide).day().month(.wide))
                            .textCase(nil)
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.paper)
            .toolbarVisibility(.hidden, for: .navigationBar)
        }
    }
}

#if DEBUG
#Preview {
    HistoryView()
        .modelContainer(SampleData.previewContainer())
}
#endif
