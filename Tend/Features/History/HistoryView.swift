import SwiftUI

struct HistoryView: View {
    var body: some View {
        ContentUnavailableView(
            "No history yet",
            systemImage: "clock.arrow.circlepath",
            description: Text("Things you mark done or snooze will appear here.")
        )
        .background(Theme.paper)
    }
}

#Preview {
    HistoryView()
}
