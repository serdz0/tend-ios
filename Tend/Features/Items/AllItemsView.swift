import SwiftData
import SwiftUI

struct AllItemsView: View {
    @Query private var items: [CareItem]
    @State private var isAdding = false

    var body: some View {
        NavigationStack {
            List {
                AllItemsHeader(onAdd: addItem)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                if items.isEmpty {
                    ContentUnavailableView {
                        Label("Nothing here yet", systemImage: "leaf")
                    } description: {
                        Text("Plants and car tasks you add will be listed here.")
                    } actions: {
                        Button("Add your first item", action: addItem)
                            .buttonStyle(.borderedProminent)
                    }
                    .listRowBackground(Color.clear)
                } else {
                    Section {
                        ForEach(items.sorted(using: KeyPathComparator(\.title, comparator: .localizedStandard))) { item in
                            ItemRow(item: item)
                                .listRowBackground(Theme.card)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.paper)
            .toolbarVisibility(.hidden, for: .navigationBar)
        }
        .sheet(isPresented: $isAdding) {
            ItemFormView()
        }
    }

    private func addItem() {
        isAdding = true
    }
}

#if DEBUG
#Preview {
    AllItemsView()
        .modelContainer(SampleData.previewContainer())
}
#endif
