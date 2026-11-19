import SwiftUI

/// "All items" in the serif title style, with the add button beside it.
struct AllItemsHeader: View {
    let onAdd: () -> Void

    var body: some View {
        HStack {
            Text("All items")
                .font(.screenTitle)
                .accessibilityAddTraits(.isHeader)
            Spacer()
            Button("Add item", systemImage: "plus", action: onAdd)
                .labelStyle(.iconOnly)
                .font(.title2)
                .buttonStyle(.borderless)
                .frame(minWidth: Theme.minimumTapSize, minHeight: Theme.minimumTapSize)
        }
    }
}
