import SwiftUI

struct TodayHeader: View {
    let now: Date

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text("Today")
                .font(.screenTitle)
                .accessibilityAddTraits(.isHeader)
            Text(now, format: .dateTime.weekday(.wide).day().month(.wide))
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
