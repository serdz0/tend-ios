import SwiftUI

/// A soft wash of colour behind the Today greeting that follows the time of day.
/// Built from the calendar tones, so it has light and dark versions already.
enum DaySky {
    static func gradient(for period: DayPeriod) -> LinearGradient {
        let tone = color(for: period)
        return LinearGradient(
            colors: [tone.opacity(0.38), tone.opacity(0.10)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }

    private static func color(for period: DayPeriod) -> Color {
        switch period {
        case .morning: Color(.honey)
        case .afternoon: Color(.sage)
        case .evening: Color(.heather)
        case .night: Color(.dusk)
        }
    }
}
