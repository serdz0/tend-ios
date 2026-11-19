import SwiftUI

/// "Every 7 days", "Every 6 months".
struct RecurrenceText: View {
    let recurrence: Recurrence

    var body: some View {
        let count = recurrence.count
        switch recurrence.unit {
        case .day: Text("Every \(count) days")
        case .week: Text("Every \(count) weeks")
        case .month: Text("Every \(count) months")
        case .year: Text("Every \(count) years")
        }
    }
}
