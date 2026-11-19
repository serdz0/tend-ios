import SwiftUI

/// A gentle question after the same thing has been snoozed three times in a row. No scolding, and easy to say no to.
struct SnoozeCheckCard: View {
    let item: CareItem
    let onChange: () -> Void
    let onDismiss: () -> Void
    let onNeverAsk: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            Label("This one keeps coming back", systemImage: "arrow.trianglehead.2.clockwise")
                .font(.headline)
            Text("You've snoozed \(item.title) a few times. That's completely fine. Want to change how often it comes up?")
                .font(.subheadline)
            Button("Change how often", action: onChange)
                .buttonStyle(.borderedProminent)
                .padding(.top, Theme.Spacing.xs)
            HStack {
                Button("Not now", action: onDismiss)
                Spacer()
                Button("Don't ask again", action: onNeverAsk)
                    .foregroundStyle(.secondary)
            }
            .buttonStyle(.borderless)
            .frame(minHeight: Theme.minimumTapSize)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
