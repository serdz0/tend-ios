import SwiftData
import UserNotifications

/// Answers taps on a reminder's Done and Snooze buttons, using the same logic as the swipes on Today.
/// Also lets a reminder show as a banner while the app is open.
final class NotificationActionHandler: NSObject, UNUserNotificationCenterDelegate {
    private let container: ModelContainer
    private let reminders: ReminderCenter
    private let settings: ReminderSettingsStore

    init(container: ModelContainer, reminders: ReminderCenter, settings: ReminderSettingsStore) {
        self.container = container
        self.reminders = reminders
        self.settings = settings
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound]
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        // Tapping the notification itself (the morning note or a reminder) lands on Today.
        if response.actionIdentifier == UNNotificationDefaultActionIdentifier {
            reminders.openToday = true
            return
        }
        guard let text = response.notification.request.content.userInfo["itemID"] as? String,
              let itemID = UUID(uuidString: text) else { return }
        await handle(action: response.actionIdentifier, itemID: itemID)
    }

    private func handle(action: String, itemID: UUID) async {
        let context = container.mainContext
        let match = FetchDescriptor<CareItem>(predicate: #Predicate { $0.id == itemID })
        guard let item = try? context.fetch(match).first else { return }

        switch action {
        case ReminderCenter.doneAction where item.distance != nil:
            reminders.itemToFinish = itemID
        case ReminderCenter.doneAction:
            item.markDone()
        case ReminderCenter.snoozeAction:
            item.snooze()
        default:
            return
        }
        try? context.save()

        await reminders.refreshStatus()
        let items = (try? context.fetch(FetchDescriptor<CareItem>())) ?? []
        await reminders.apply(ReminderPlanner.plans(for: items, settings: settings.settings))
    }
}
