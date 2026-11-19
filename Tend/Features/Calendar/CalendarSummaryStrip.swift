import SwiftUI

/// "What needs doing" in one glance: a warm sentence and three counts.
struct CalendarSummaryStrip: View {
    let summary: CareSummary

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            Text(summary.headline)
                .font(.headline)
                .fontDesign(.serif)

            ViewThatFits(in: .horizontal) {
                HStack(spacing: Theme.Spacing.s) { tiles }
                VStack(spacing: Theme.Spacing.s) { tiles }
            }
        }
        .padding(.vertical, Theme.Spacing.xs)
    }

    @ViewBuilder
    private var tiles: some View {
        CalendarSummaryTile(count: summary.overdue, title: "Overdue", tint: Theme.overdue)
        CalendarSummaryTile(count: summary.today, title: "Today", tint: Color.accentColor)
        CalendarSummaryTile(count: summary.thisWeek, title: "Next 7 days", tint: Color(.dusk))
    }
}
