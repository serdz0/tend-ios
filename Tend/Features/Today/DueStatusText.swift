import SwiftUI

/// "3 days overdue", "Today", "in 12 days". Words, so it never relies on colour alone.
/// For tasks that repeat by distance the day is an estimate, so it says "in about".
struct DueStatusText: View {
    let status: DueStatus
    var isEstimate = false

    var body: some View {
        switch status {
        case .overdue(let days):
            Text("^[\(days) day](inflect: true) overdue")
        case .dueToday:
            Text("Today")
        case .upcoming(let days):
            if isEstimate {
                Text("In about ^[\(days) day](inflect: true)")
            } else {
                Text("In ^[\(days) day](inflect: true)")
            }
        }
    }
}
