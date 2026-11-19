import SwiftUI

/// One thing on a day: due, expected later, done or snoozed.
struct CalendarEntryRow: View {
    let entry: CalendarEntry
    let now: Date

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        HStack(spacing: Theme.Spacing.m) {
            if !dynamicTypeSize.isAccessibilitySize {
                CategoryBadge(category: entry.category, isFaded: entry.kind == .expected)
            }
            VStack(alignment: .leading) {
                Text(entry.item.title)
                detail
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }

    @ViewBuilder
    private var detail: some View {
        switch entry.kind {
        case .due:
            let status = entry.item.status(now: now)
            DueStatusText(status: status, isEstimate: entry.item.distance != nil)
                .foregroundStyle(status.isOverdue ? Theme.overdue : Color.secondary)
        case .expected:
            Text("Expected, if all goes to plan")
        case .done:
            Text("Done at \(entry.date, format: .dateTime.hour().minute())")
        case .snoozed:
            Text("Snoozed at \(entry.date, format: .dateTime.hour().minute())")
        }
    }
}
