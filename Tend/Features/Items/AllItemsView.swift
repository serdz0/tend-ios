import SwiftData
import SwiftUI

struct AllItemsView: View {
    @Query(sort: \CareItem.name) private var items: [CareItem]

    var body: some View {
        NavigationStack {
            List(items) { item in
                VStack(alignment: .leading) {
                    Text(item.title)
                    RecurrenceText(recurrence: item.recurrence)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .listRowBackground(Theme.card)
            }
            .overlay {
                if items.isEmpty {
                    ContentUnavailableView(
                        "Nothing here yet",
                        systemImage: "leaf",
                        description: Text("Plants and car tasks you add will be listed here.")
                    )
                }
            }
            .scrollContentBackground(.hidden)
            .background(Theme.paper)
            .navigationTitle("All items")
        }
    }
}

#if DEBUG
#Preview {
    AllItemsView()
        .modelContainer(SampleData.previewContainer())
}
#endif
