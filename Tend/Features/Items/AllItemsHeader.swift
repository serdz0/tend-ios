import SwiftUI

/// "My things" in the serif title style, a short welcome line, and the add button beside it.
struct AllItemsHeader: View {
    let onAdd: () -> Void

    var body: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: Theme.Spacing.xs) {
                Text("My things")
                    .font(.screenTitle)
                    .accessibilityAddTraits(.isHeader)
                Text("Everything you look after, all in one place.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            Button("Add something", systemImage: "plus", action: onAdd)
                .labelStyle(.iconOnly)
                .font(.title2)
                .buttonStyle(.borderless)
                .frame(minWidth: Theme.minimumTapSize, minHeight: Theme.minimumTapSize)
        }
    }
}
