import Foundation

/// One notification the app wants on the phone: what it says and when it arrives.
nonisolated struct ReminderPlan: Hashable {
    let identifier: String
    /// Nil for the morning note, which covers several things.
    let itemID: UUID?
    let fireDate: Date
    let title: String
    let body: String
    /// True for tasks that repeat by distance: Done has to open the app to ask for the odometer.
    let needsOdometer: Bool
}
