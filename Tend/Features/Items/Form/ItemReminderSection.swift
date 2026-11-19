import SwiftUI

/// The time of day the reminder arrives.
struct ItemReminderSection: View {
    @Binding var draft: ItemDraft

    var body: some View {
        Section {
            DatePicker("Remind me at", selection: $draft.reminderDate, displayedComponents: .hourAndMinute)
        } footer: {
            Text("The time of day for this item's reminder.")
        }
    }
}
