import SwiftUI

/// The title above one group on My things: "Plants" or a car's name, with how many are in it.
struct ItemGroupHeader: View {
    let group: ItemGroup

    var body: some View {
        HStack {
            Label(group.title, systemImage: group.kind.symbolName)
                .font(.headline)
                .foregroundStyle(.primary)
            Spacer()
            switch group.kind {
            case .plant: Text("^[\(group.items.count) plant](inflect: true)")
            case .car: Text("^[\(group.items.count) task](inflect: true)")
            }
        }
        .textCase(nil)
    }
}
