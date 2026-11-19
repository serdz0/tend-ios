import SwiftUI

/// The top of the detail screen: what it is, when it is due, and the Done and Snooze buttons.
struct ItemDueSection: View {
    let item: CareItem
    let now: Date
    let onDone: () -> Void
    let onSnooze: () -> Void

    var body: some View {
        let status = item.status(now: now)

        Section {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Label(item.title, systemImage: item.kind.symbolName)
                    .font(.title2.bold())
                    .fontDesign(.serif)
                DueStatusText(status: status, isEstimate: item.distance != nil)
                    .font(.headline)
                    .foregroundStyle(status.isOverdue ? Theme.overdue : Color.primary)
                Text(item.dueDate, format: .dateTime.weekday(.wide).day().month(.wide).year())
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                if let distance = item.distance {
                    KilometresLeftText(distance: distance, now: now)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .listRowBackground(Theme.card)
        }

        Section {
            Button(action: onDone) {
                Label("Mark as done", systemImage: "checkmark.circle")
                    .labelStyle(.titleAndIcon)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.borderedProminent)

            Button(action: onSnooze) {
                Label("Snooze for a day", systemImage: "zzz")
                    .labelStyle(.titleAndIcon)
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(.bordered)
        }
        .listRowBackground(Color.clear)
        .listRowSeparator(.hidden)
    }
}
