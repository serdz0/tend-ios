import SwiftUI

/// One history entry: Done or Snoozed, in words and with an icon.
struct HistoryEventRow: View {
    let event: CareEvent
    /// On the History tab the row names the item. On an item's own screen it names the date instead.
    var showsItemTitle = true

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @ScaledMetric(relativeTo: .title3) private var iconWidth = Theme.Spacing.l

    var body: some View {
        HStack(spacing: Theme.Spacing.m) {
            if !dynamicTypeSize.isAccessibilitySize {
                Image(systemName: event.kind.symbolName)
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: iconWidth)
                    .accessibilityHidden(true)
            }

            VStack(alignment: .leading) {
                if showsItemTitle {
                    Text(event.item?.title ?? String(localized: "Something you removed"))
                    Text("\(event.kind.title) at \(event.date, format: .dateTime.hour().minute())")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                } else {
                    Text(event.kind.title)
                    Text(event.date, format: .dateTime.weekday(.abbreviated).day().month().hour().minute())
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }
}
