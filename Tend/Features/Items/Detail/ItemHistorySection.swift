import SwiftUI

/// The item's own history, newest first.
struct ItemHistorySection: View {
    let item: CareItem

    var body: some View {
        Section("History") {
            if item.events.isEmpty {
                Text("Nothing yet. When you mark it done or snooze it, it shows up here.")
                    .foregroundStyle(.secondary)
            } else {
                ForEach(item.events.sorted { $0.date > $1.date }) { event in
                    HistoryEventRow(event: event, showsItemTitle: false)
                }
            }
        }
        .listRowBackground(Theme.card)
    }
}
