import SwiftUI

/// The time of day the reminder arrives, and a hint if reminders are switched off.
struct ItemReminderSection: View {
    @Binding var draft: ItemDraft

    @Environment(ReminderCenter.self) private var reminders
    @Environment(\.openURL) private var openURL

    var body: some View {
        Section {
            DatePicker("Remind me at", selection: $draft.reminderDate, displayedComponents: .hourAndMinute)
            if reminders.status == .denied {
                Button("Reminders are off. Open Settings to turn them on.", systemImage: "bell.slash", action: openSettings)
            }
        } footer: {
            Text("The time of day for a gentle nudge.")
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }
}
