import SwiftUI

/// One count in the summary: a number and what it counts, on a soft tint.
struct CalendarSummaryTile: View {
    let count: Int
    let title: LocalizedStringKey
    let tint: Color

    var body: some View {
        VStack(spacing: 0) {
            Text(count, format: .number)
                .font(.title.bold())
                .fontDesign(.serif)
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, Theme.Spacing.s)
        .background(tint.opacity(0.18), in: .rect(cornerRadius: 12))
        .accessibilityElement(children: .combine)
    }
}
