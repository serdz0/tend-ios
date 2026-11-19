import SwiftUI

/// One group on the Today screen: "Waiting for you", "For today" or "Coming up".
struct CareSection: View {
    let title: LocalizedStringKey
    let items: [CareItem]
    let now: Date
    let completing: Set<UUID>
    let onDone: (CareItem) -> Void
    let onSnooze: (CareItem) -> Void

    var body: some View {
        if !items.isEmpty {
            Section {
                ForEach(items) { item in
                    CareRow(
                        item: item,
                        status: item.status(now: now),
                        now: now,
                        isCompleting: completing.contains(item.id),
                        onDone: { onDone(item) }
                    )
                    .listRowBackground(Theme.card)
                    .swipeActions(edge: .leading) {
                        Button("Done", systemImage: "checkmark") { onDone(item) }
                            .tint(.accentColor)
                    }
                    .swipeActions(edge: .trailing) {
                        Button("Snooze", systemImage: "zzz") { onSnooze(item) }
                            .tint(.gray)
                    }
                }
            } header: {
                Text(title)
                    .textCase(nil)
            }
        }
    }
}
