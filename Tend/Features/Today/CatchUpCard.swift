import SwiftUI

/// A gentle card for when things have piled up or you have been away: no scolding, just a way back in.
struct CatchUpCard: View {
    let welcome: WelcomeBack?
    let freshStart: FreshStart?
    let onFreshStart: () -> Void
    let onDismiss: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: Theme.Spacing.s) {
            if let welcome {
                Label(welcome.title, systemImage: "hand.wave")
                    .font(.headline)
                Text(welcome.message)
                    .font(.subheadline)
                Text(welcome.suggestion)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            if let freshStart {
                if welcome == nil {
                    Label("A fresh start?", systemImage: "sparkles")
                        .font(.headline)
                }
                Text("Tend can spread \(freshStart.moves.count) thirsty plants over the next few days, two a day. Car deadlines stay where they are.")
                    .font(.subheadline)
                    .foregroundStyle(welcome == nil ? .primary : .secondary)
                Button("Spread them out", action: onFreshStart)
                    .buttonStyle(.borderedProminent)
                    .padding(.top, Theme.Spacing.xs)
            }

            Button(freshStart == nil ? "Got it" : "Not now", action: onDismiss)
                .buttonStyle(.borderless)
                .frame(minHeight: Theme.minimumTapSize)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
