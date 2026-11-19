import SwiftData
import SwiftUI

/// "My things": plants first, then each car, soonest due first within each group.
struct AllItemsView: View {
    @Query private var items: [CareItem]
    @State private var isAdding = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var now = Date.now

    var body: some View {
        NavigationStack {
            List {
                AllItemsHeader(onAdd: addItem)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                if items.isEmpty {
                    ContentUnavailableView {
                        Label("Let's add your first thing", systemImage: "leaf")
                    } description: {
                        Text("Add a plant or a car task and Tend will remind you when it needs you.")
                    } actions: {
                        Button("Add something", action: addItem)
                            .buttonStyle(.borderedProminent)
                    }
                    .listRowBackground(Color.clear)
                } else {
                    ForEach(ItemGroup.groups(from: items)) { group in
                        Section {
                            ForEach(group.items) { item in
                                NavigationLink(value: item) {
                                    ItemRow(item: item, now: now)
                                }
                                .listRowBackground(Theme.card)
                            }
                        } header: {
                            ItemGroupHeader(group: group)
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.paper)
            .toolbarVisibility(.hidden, for: .navigationBar)
            .navigationDestination(for: CareItem.self) { item in
                ItemDetailView(item: item)
            }
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active { now = .now }
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
