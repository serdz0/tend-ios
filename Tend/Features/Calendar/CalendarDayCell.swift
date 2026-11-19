import SwiftUI

/// One day in the month grid: its number, a soft tint and a few coloured dots for what is on it.
struct CalendarDayCell: View {
    let day: Date
    let isToday: Bool
    let isSelected: Bool
    let hasDueItem: Bool
    let categories: [CareCategory]
    let entryCount: Int
    let onSelect: () -> Void

    @ScaledMetric(relativeTo: .body) private var circleSize = 30.0

    var body: some View {
        Button(action: onSelect) {
            VStack(spacing: 2) {
                Text(day, format: .dateTime.day())
                    .fontWeight(isToday ? .bold : .regular)
                    .foregroundStyle(isSelected ? Theme.paper : Color.primary)
                    .frame(width: circleSize, height: circleSize)
                    .background(isSelected ? Color.accentColor : Color.clear, in: .circle)
                    .overlay {
                        if isToday && !isSelected {
                            Circle().strokeBorder(Color.accentColor, lineWidth: 1.5)
                        }
                    }
                HStack(spacing: 3) {
                    ForEach(categories.prefix(3), id: \.self) { category in
                        Circle()
                            .fill(category.color)
                            .frame(width: 6, height: 6)
                    }
                }
                .frame(height: 6)
            }
            .frame(maxWidth: .infinity, minHeight: Theme.minimumTapSize)
            .background {
                RoundedRectangle(cornerRadius: 10).fill(tint).padding(2)
            }
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
        .accessibilityLabel(accessibilityText)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }

    /// A soft wash on days where something is due. A car task's colour wins over the plants',
    /// because plants are on most days and would turn the whole month green.
    private var tint: Color {
        guard hasDueItem else { return .clear }
        let main = categories.first { $0 != .plant } ?? categories.first
        return main?.color.opacity(0.2) ?? .clear
    }

    private var accessibilityText: String {
        let date = day.formatted(.dateTime.weekday(.wide).day().month(.wide))
        guard entryCount > 0 else { return date }
        return date + ", " + String(localized: "\(entryCount) things")
    }
}
