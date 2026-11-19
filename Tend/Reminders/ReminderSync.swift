import Foundation

/// What the phone's schedule should match. When this changes, the reminders are scheduled again.
struct ReminderSync: Hashable {
    let plans: [ReminderPlan]
    let status: ReminderCenter.Status
}
