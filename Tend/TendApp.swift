import SwiftData
import SwiftUI
import UserNotifications

@main
struct TendApp: App {
    private let container: ModelContainer
    private let reminders = ReminderCenter()
    private let reminderSettings = ReminderSettingsStore()
    private let actionHandler: NotificationActionHandler

    init() {
        let container: ModelContainer
        do {
            container = try ModelContainer(for: CareItem.self, CareEvent.self)
        } catch {
            fatalError("Couldn't open the database: \(error)")
        }
        #if DEBUG
        SampleData.seedIfEmpty(in: container.mainContext)
        #endif
        self.container = container

        // The system keeps only a weak reference to its delegate, so the app holds on to it.
        let handler = NotificationActionHandler(container: container, reminders: reminders, settings: reminderSettings)
        actionHandler = handler
        reminders.registerCategories()
        UNUserNotificationCenter.current().delegate = handler
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
        .environment(reminders)
        .environment(reminderSettings)
    }
}
