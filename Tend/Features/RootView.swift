import SwiftData
import SwiftUI

struct RootView: View {
    @State private var selection: AppTab = .today

    var body: some View {
        TabView(selection: $selection) {
            Tab("Today", systemImage: "sun.max", value: AppTab.today) {
                TodayView()
            }
            Tab("Calendar", systemImage: "calendar", value: AppTab.calendar) {
                CalendarView()
            }
            Tab("My things", systemImage: "tray.full", value: AppTab.items) {
                AllItemsView()
            }
            Tab("Journal", systemImage: "book", value: AppTab.history) {
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
