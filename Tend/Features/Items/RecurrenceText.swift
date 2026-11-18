import SwiftUI

/// "Every 7 days", "Every 6 months".
struct RecurrenceText: View {
    let recurrence: Recurrence

    var body: some View {
        let count = recurrence.count
        switch recurrence.unit {
        case .day: Text("Every ^[\(count) day](inflect: true)")
        case .week: Text("Every ^[\(count) week](inflect: true)")
        case .month: Text("Every ^[\(count) month](inflect: true)")
        case .year: Text("Every ^[\(count) year](inflect: true)")
        }
    }
}
