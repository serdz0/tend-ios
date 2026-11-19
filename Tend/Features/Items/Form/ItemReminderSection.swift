import SwiftUI

/// The time of day the reminder arrives, and a hint if reminders are switched off.
struct ItemReminderSection: View {
    @Binding var draft: ItemDraft

    @Environment(ReminderCenter.self) private var reminders
    @Environment(ReminderSettingsStore.self) private var settings
    @Environment(\.openURL) private var openURL

    var body: some View {
        Section {
            if settings.settings.style == .perItem {
                DatePicker("Remind me at", selection: $draft.reminderDate, displayedComponents: .hourAndMinute)
            } else {
                Label("This shows up in your morning note.", systemImage: "sun.max")
            }
            if reminders.status == .denied {
                Button("Reminders are off. Open Settings to turn them on.", systemImage: "bell.slash", action: openSettings)
            }
        } footer: {
            Text(settings.settings.style == .perItem
                 ? "The time of day for a gentle nudge."
                 : "You can switch to a note for each thing under \"How Tend talks to you\" on Today.")
        }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }
}
