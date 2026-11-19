import SwiftUI

/// A small label that points at the one thing to begin with.
struct StartHereBadge: View {
    var body: some View {
        HStack(spacing: Theme.Spacing.xs) {
            Image(systemName: "arrow.right")
                .accessibilityHidden(true)
            Text("Start here")
        }
            .font(.caption.weight(.semibold))
            .fontDesign(.rounded)
            .foregroundStyle(Color.accentColor)
            .padding(.horizontal, Theme.Spacing.s)
            .padding(.vertical, Theme.Spacing.xs)
            .background(Color.accentColor.opacity(0.14), in: .capsule)
    }
}
