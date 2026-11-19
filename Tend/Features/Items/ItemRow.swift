import SwiftUI

/// One line in the All items list: icon, name and how often it repeats.
struct ItemRow: View {
    let item: CareItem

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .title3) private var iconWidth = Theme.Spacing.l

    var body: some View {
        HStack(spacing: Theme.Spacing.m) {
            if !dynamicTypeSize.isAccessibilitySize {
                Image(systemName: item.kind.symbolName)
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: iconWidth)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading) {
                Text(item.title)
                ScheduleText(schedule: item.schedule)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
        }
    }
}
