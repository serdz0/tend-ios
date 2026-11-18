import SwiftUI

struct CareRow: View {
    let item: CareItem
    let status: DueStatus
    let isCompleting: Bool
    let onDone: () -> Void

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .title3) private var iconWidth = Theme.Spacing.l

    var body: some View {
        HStack(spacing: Theme.Spacing.m) {
            if !dynamicTypeSize.isAccessibilitySize {
                Image(systemName: item.kind.symbolName)
                    .font(.title3)
                    .foregroundStyle(status.isOverdue ? Theme.overdue : Color.accentColor)
                    .frame(width: iconWidth)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading) {
                Text(item.title)
                DueStatusText(status: status)
                    .font(.subheadline)
                    .foregroundStyle(status.isOverdue ? Theme.overdue : Color.secondary)
            }

            Spacer()

            Button(action: onDone) {
                Label("Mark done", systemImage: isCompleting ? "checkmark.circle.fill" : "circle")
                    .labelStyle(.iconOnly)
                    .font(.title)
                    .contentTransition(.symbolEffect(.replace))
            }
            .buttonStyle(.borderless)
            .frame(minWidth: Theme.minimumTapSize, minHeight: Theme.minimumTapSize)
            .accessibilityLabel("Mark \(item.title) done")
        }
    }
}
