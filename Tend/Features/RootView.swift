import SwiftData
import SwiftUI

struct RootView: View {
    @Query private var items: [CareItem]
    @Environment(ReminderCenter.self) private var reminders
    @Environment(\.scenePhase) private var scenePhase
    @State private var selection: AppTab = .today
    @State private var now = Date.now

    var body: some View {
        let sync = ReminderSync(
            plans: ReminderPlanner.plans(for: items, now: now),
            status: reminders.status
        )

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
        .task {
            await reminders.refreshStatus()
        }
        // Runs again only when the reminders themselves change, so the phone's schedule stays in step
        // with every add, edit, done, snooze and delete.
        .task(id: sync) {
            await reminders.apply(sync.plans)
            #if DEBUG
            await sendTestReminderIfAsked()
            #endif
        }
        .onChange(of: scenePhase) {
            guard scenePhase == .active else { return }
            now = .now
            Task { await reminders.refreshStatus() }
        }
        .onChange(of: reminders.itemToFinish) {
            if reminders.itemToFinish != nil { selection = .today }
        }
    }

    #if DEBUG
    /// Launch with `-testReminder Oil` to get a reminder for the first item whose title contains "Oil" in ten seconds.
    private func sendTestReminderIfAsked() async {
        guard let word = UserDefaults.standard.string(forKey: "testReminder"),
              let item = items.first(where: { $0.title.localizedCaseInsensitiveContains(word) }) else { return }
        await reminders.scheduleTestReminder(for: item)
    }
    #endif
}

#if DEBUG
#Preview {
    RootView()
        .modelContainer(SampleData.previewContainer())
        .environment(ReminderCenter())
}
#endif
