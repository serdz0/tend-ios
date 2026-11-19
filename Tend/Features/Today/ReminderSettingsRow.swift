import SwiftUI

/// A quiet row at the bottom of Today that says how Tend reminds you and opens the settings.
struct ReminderSettingsRow: View {
    let settings: ReminderSettings
    let now: Date
    let onOpen: () -> Void

    var body: some View {
        Button(action: onOpen) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Label("How Tend talks to you", systemImage: "bell")
                    .foregroundStyle(.primary)
                Group {
                    if let until = settings.activePause(now: now) {
                        Text("Quiet until \(until, format: .dateTime.weekday(.wide).day().month(.wide))")
                    } else {
                        Text(settings.summary)
                    }
                }
                .font(.subheadline)
                .foregroundStyle(.secondary)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .frame(minHeight: Theme.minimumTapSize)
            .contentShape(.rect)
        }
        .buttonStyle(.plain)
    }
}
