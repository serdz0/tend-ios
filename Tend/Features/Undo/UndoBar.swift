import SwiftUI

/// A bar at the bottom of the screen that says what just happened and offers to take it back.
/// It has no timer: it stays until you tap Undo, close it, or do something else.
struct UndoBar: View {
    let message: String
    let onUndo: () -> Void
    let onClose: () -> Void

    var body: some View {
        ViewThatFits(in: .horizontal) {
            HStack(spacing: Theme.Spacing.s) {
                Text(message)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                undoButton
                closeButton
            }
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text(message)
                    .font(.subheadline)
                    .padding(.top, Theme.Spacing.s)
                HStack {
                    undoButton
                    Spacer()
                    closeButton
                }
            }
        }
        .padding(.leading, Theme.Spacing.m)
        .padding(.trailing, Theme.Spacing.xs)
        .padding(.vertical, Theme.Spacing.xs)
        .background(Theme.card, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .strokeBorder(.secondary.opacity(0.25))
        }
        .shadow(color: .black.opacity(0.12), radius: 8, y: 2)
        .padding(.horizontal, Theme.Spacing.m)
        .padding(.bottom, Theme.Spacing.s)
        .accessibilityElement(children: .contain)
        .onAppear(perform: announce)
    }

    private var undoButton: some View {
        Button("Undo", action: onUndo)
            .fontWeight(.semibold)
            .frame(minHeight: Theme.minimumTapSize)
            .padding(.horizontal, Theme.Spacing.s)
    }

    private var closeButton: some View {
        Button(action: onClose) {
            Label("Close", systemImage: "xmark")
                .labelStyle(.iconOnly)
                .foregroundStyle(.secondary)
        }
        .frame(minWidth: Theme.minimumTapSize, minHeight: Theme.minimumTapSize)
    }

    private func announce() {
        AccessibilityNotification.Announcement("\(message) Undo is available.").post()
    }
}

#if DEBUG
#Preview {
    VStack {
        Spacer()
        UndoBar(message: "Water Basil is done.", onUndo: {}, onClose: {})
    }
    .background(Theme.paper)
}
#endif
