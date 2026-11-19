import SwiftUI

/// A greeting, today's date and one warm sentence about what is waiting.
struct TodayHeader: View {
    let now: Date
    let summary: CareSummary

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(Greeting.text(at: now))
                .font(.screenTitle)
                .accessibilityAddTraits(.isHeader)
            Text(now, format: .dateTime.weekday(.wide).day().month(.wide))
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(summary.headline)
                .font(.title3)
                .fontDesign(.serif)
                .padding(.top, Theme.Spacing.s)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
