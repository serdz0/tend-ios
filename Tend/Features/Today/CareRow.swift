import SwiftUI

struct CareRow: View {
    let item: CareItem
    let status: DueStatus
    let now: Date
    let isCompleting: Bool
    var isStartHere = false
    let onDone: () -> Void

    @AppStorage("playfulExtras") private var playfulExtras = true
    @Environment(\.accessibilityReduceMotion) private var reduceMotion
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
                if isStartHere {
                    StartHereBadge()
                }
                Text(item.title)
                DueStatusText(status: status, isEstimate: item.distance != nil)
                    .font(.subheadline)
                    .foregroundStyle(status.isOverdue ? Theme.overdue : Color.secondary)
                if let distance = item.distance {
                    KilometresLeftText(distance: distance, now: now)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }

            Spacer()

            Button(action: onDone) {
                Label("Mark done", systemImage: isCompleting ? "checkmark.circle.fill" : "circle")
                    .labelStyle(.iconOnly)
                    .font(.title)
                    .contentTransition(.symbolEffect(.replace))
                    .scaleEffect(isCompleting && playfulExtras && !reduceMotion ? 1.2 : 1)
                    .animation(.spring(duration: 0.4, bounce: 0.55), value: isCompleting)
            }
            .overlay {
                if playfulExtras, !reduceMotion {
                    LeafBurst(isActive: isCompleting)
                }
            }
            .sensoryFeedback(.success, trigger: isCompleting) { _, finished in
                finished && playfulExtras
            }
            .buttonStyle(.borderless)
            .frame(minWidth: Theme.minimumTapSize, minHeight: Theme.minimumTapSize)
            .accessibilityLabel("Mark \(item.title) done")
        }
    }
}
