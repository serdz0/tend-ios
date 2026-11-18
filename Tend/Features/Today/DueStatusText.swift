import SwiftUI

/// "3 days overdue", "Today", "in 12 days". Words, so it never relies on colour alone.
struct DueStatusText: View {
    let status: DueStatus

    var body: some View {
        switch status {
        case .overdue(let days):
            Text("^[\(days) day](inflect: true) overdue")
        case .dueToday:
            Text("Today")
        case .upcoming(let days):
            Text("In ^[\(days) day](inflect: true)")
        }
    }
}
