import SwiftUI

/// A friendly question before the system's own permission popup: want reminders?
struct ReminderPromptCard: View {
    @Environment(ReminderCenter.self) private var reminders

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            Label("Want a gentle nudge?", systemImage: "bell")
                .font(.headline)
            Text("Tend can remind you when something is due, so you never have to remember. Just the things you've added, nothing else.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Button("Turn on reminders", action: turnOn)
                .buttonStyle(.borderedProminent)
                .padding(.top, Theme.Spacing.xs)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func turnOn() {
        Task { await reminders.requestPermission() }
    }
}
