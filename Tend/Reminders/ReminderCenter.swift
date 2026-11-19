import Foundation
import Observation
import UserNotifications

/// Talks to the system about notifications: asks permission, keeps the scheduled reminders in step
/// with the items, and remembers when a notification's Done button needs the odometer.
@Observable
final class ReminderCenter {
    enum Status: Hashable {
        /// Not looked up yet.
        case unknown
        /// The person has not been asked.
        case notDetermined
        case denied
        case allowed
    }

    static let plainCategory = "care-item"
    static let distanceCategory = "care-item-distance"
    static let doneAction = "done"
    static let snoozeAction = "snooze"
    private static let idPrefix = "care-"

    private(set) var status: Status = .unknown
    /// Set when Done was tapped on a reminder for a task that repeats by distance.
    /// The Today screen opens the odometer sheet for it and clears this.
    var itemToFinish: UUID?
    /// Set when a notification is tapped, so the app lands on Today. Cleared once it has.
    var openToday = false

    private let center = UNUserNotificationCenter.current()

    /// The Done and Snooze buttons on a reminder. Call once at launch.
    func registerCategories() {
        let snooze = UNNotificationAction(identifier: Self.snoozeAction, title: String(localized: "Snooze for a day"), options: [])
        // Done runs in the background, except for distance tasks, which open the app to ask for the odometer.
        let done = UNNotificationAction(identifier: Self.doneAction, title: String(localized: "Done"), options: [])
        let doneInApp = UNNotificationAction(identifier: Self.doneAction, title: String(localized: "Done"), options: [.foreground])
        center.setNotificationCategories([
            UNNotificationCategory(identifier: Self.plainCategory, actions: [done, snooze],
                                   intentIdentifiers: [], options: []),
            UNNotificationCategory(identifier: Self.distanceCategory, actions: [doneInApp, snooze],
                                   intentIdentifiers: [], options: []),
        ])
    }

    func refreshStatus() async {
        let settings = await center.notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined: status = .notDetermined
        case .denied: status = .denied
        default: status = .allowed
        }
    }

    func requestPermission() async {
        _ = try? await center.requestAuthorization(options: [.alert, .sound])
        await refreshStatus()
    }

    /// Replaces the scheduled reminders with these. Does nothing until the person has allowed notifications.
    func apply(_ plans: [ReminderPlan]) async {
        guard status == .allowed else { return }
        let pending = await center.pendingNotificationRequests()
        let ours = pending.map(\.identifier).filter { $0.hasPrefix(Self.idPrefix) }
        center.removePendingNotificationRequests(withIdentifiers: ours)

        for plan in plans {
            let content = UNMutableNotificationContent()
            content.title = plan.title
            content.body = plan.body
            content.sound = .default
            // The morning note has no buttons: it only opens Today.
            if let itemID = plan.itemID {
                content.categoryIdentifier = plan.needsOdometer ? Self.distanceCategory : Self.plainCategory
                content.userInfo = ["itemID": itemID.uuidString]
            }

            let parts = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: plan.fireDate)
            let trigger = UNCalendarNotificationTrigger(dateMatching: parts, repeats: false)
            try? await center.add(UNNotificationRequest(identifier: plan.identifier, content: content, trigger: trigger))
        }
        #if DEBUG
        NSLog("Tend scheduled %d reminders: %@", plans.count, plans.prefix(3).map { "\($0.title) at \($0.fireDate)" }.joined(separator: "; "))
        #endif
    }

    #if DEBUG
    /// For trying the buttons in the simulator: a reminder for this item in ten seconds.
    func scheduleTestReminder(for item: CareItem) async {
        guard status == .allowed else { return }
        let content = UNMutableNotificationContent()
        content.title = item.title
        content.body = "Test reminder. Pull down and try the buttons." // debug only
        content.sound = .default
        content.categoryIdentifier = item.distance != nil ? Self.distanceCategory : Self.plainCategory
        content.userInfo = ["itemID": item.id.uuidString]
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
        try? await center.add(UNNotificationRequest(identifier: "test-reminder", content: content, trigger: trigger))
    }
    #endif
}
