import SwiftUI

/// The month as a grid of days. Kept short, so the summary fits underneath without scrolling.
struct CalendarGrid: View {
    let month: CalendarMonth
    let selectedDay: Date
    let now: Date
    let entries: CalendarEntries
    let onSelect: (Date) -> Void

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 0), count: 7)

    var body: some View {
        let calendar = Calendar.current

        VStack(spacing: Theme.Spacing.xs) {
            HStack(spacing: 0) {
                ForEach(month.weekdaySymbols, id: \.self) { symbol in
                    Text(symbol)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .accessibilityHidden(true)

            LazyVGrid(columns: columns, spacing: 0) {
                ForEach(Array(month.cells.enumerated()), id: \.offset) { _, cell in
                    if let day = cell {
                        let dayEntries = entries.entries(on: day)
                        CalendarDayCell(
                            day: day,
                            isToday: calendar.isDate(day, inSameDayAs: now),
                            isSelected: calendar.isDate(day, inSameDayAs: selectedDay),
                            hasDueItem: dayEntries.contains { $0.kind == .due },
                            categories: entries.categories(on: day),
                            entryCount: dayEntries.count,
                            onSelect: { onSelect(day) }
                        )
                    } else {
                        Color.clear.frame(height: Theme.minimumTapSize)
                    }
                }
            }
        }
    }
}
