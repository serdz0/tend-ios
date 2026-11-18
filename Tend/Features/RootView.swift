import SwiftData
import SwiftUI

struct RootView: View {
    @State private var selection: AppTab = .today

    var body: some View {
        TabView(selection: $selection) {
            Tab("Today", systemImage: "calendar", value: AppTab.today) {
                TodayView()
            }
            Tab("All items", systemImage: "list.bullet", value: AppTab.items) {
                AllItemsView()
            }
            Tab("History", systemImage: "clock.arrow.circlepath", value: AppTab.history) {
                HistoryView()
            }
        }
    }
}

#if DEBUG
#Preview {
    RootView()
        .modelContainer(SampleData.previewContainer())
}
#endif
