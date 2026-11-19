import SwiftUI

/// A greeting, today's date and one warm sentence about what is waiting.
struct TodayHeader: View {
    let now: Date
    let summary: CareSummary
    let mood: DayMood

    @Environment(\.dynamicTypeSize) private var dynamicTypeSize

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
            Text(Greeting.text(at: now))
                .font(.screenTitle)
                .accessibilityAddTraits(.isHeader)
            HStack(alignment: .center, spacing: Theme.Spacing.m) {
                VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                    Text(now, format: .dateTime.weekday(.wide).day().month(.wide))
                        .font(.subheadline)
                        // Darker than plain secondary, which is too faint on the tinted sky.
                        .foregroundStyle(Color.primary.opacity(0.72))
                    Text(summary.headline)
                        .font(.title3)
                        .fontDesign(.serif)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if !dynamicTypeSize.isAccessibilitySize {
                    SproutView(kind: mood.kind)
                        .accessibilityElement()
                        .accessibilityLabel(mood.sentence)
                }
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(Theme.Spacing.m)
        .background(DaySky.gradient(for: DayPeriod.of(now)), in: .rect(cornerRadius: Theme.Spacing.l))
    }
}
