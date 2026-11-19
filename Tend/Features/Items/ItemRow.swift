import SwiftUI

/// One line in My things: icon, name, how often it repeats, and when it is next due.
struct ItemRow: View {
    let item: CareItem
    let now: Date

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .title3) private var iconWidth = Theme.Spacing.l

    var body: some View {
        let status = item.status(now: now)

        HStack(spacing: Theme.Spacing.m) {
            if !dynamicTypeSize.isAccessibilitySize {
                Image(systemName: item.kind.symbolName)
                    .font(.title3)
                    .foregroundStyle(status.isOverdue ? Theme.overdue : Color.accentColor)
                    .frame(width: iconWidth)
                    .accessibilityHidden(true)
            }

            ViewThatFits(in: .horizontal) {
                HStack {
                    titleAndSchedule
                    Spacer(minLength: Theme.Spacing.s)
                    dueText(status)
                }
                VStack(alignment: .leading) {
                    titleAndSchedule
                    dueText(status)
                }
            }
        }
    }

    private var titleAndSchedule: some View {
        VStack(alignment: .leading) {
            Text(item.title)
            ScheduleLine(item: item)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private func dueText(_ status: DueStatus) -> some View {
        DueStatusText(status: status, isEstimate: item.distance != nil)
            .font(.subheadline)
            .foregroundStyle(status.isOverdue ? Theme.overdue : Color.secondary)
    }
}
