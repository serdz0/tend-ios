import SwiftUI

/// "3 days overdue", "Due today", "Tomorrow", "In 12 days". Words, so it never relies on colour alone.
/// For tasks that repeat by distance the day is an estimate, so it says "in about".
struct DueStatusText: View {
    let status: DueStatus
    var isEstimate = false

    var body: some View {
        switch status {
        case .overdue(let days):
            Text("\(days) days overdue")
        case .dueToday:
            Text("Due today")
        case .upcoming(let days) where days == 1:
            if isEstimate {
                Text("Around tomorrow")
            } else {
                Text("Tomorrow")
            }
        case .upcoming(let days):
            if isEstimate {
                Text("In about \(days) days")
            } else {
                Text("In \(days) days")
            }
        }
    }
}
