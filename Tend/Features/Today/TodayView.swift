import SwiftData
import SwiftUI

struct TodayView: View {
    @Query(sort: \CareItem.dueDate) private var items: [CareItem]
    @Environment(\.scenePhase) private var scenePhase
    @State private var now = Date.now
    /// Items whose tick is showing for a moment before they leave the list.
    @State private var completing: Set<UUID> = []
    /// Set when an item that repeats by distance is marked done: it needs an odometer reading first.
    @State private var odometerRequest: OdometerRequest?

    var body: some View {
        let sections = TodaySections(items: items, now: now)

        NavigationStack {
            List {
                TodayHeader(now: now)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                if !sections.hasWork {
                    ContentUnavailableView(
                        "All done for today",
                        systemImage: "checkmark.circle",
                        description: Text("Nothing is waiting. Enjoy the day.")
                    )
                    .listRowBackground(Color.clear)
                }

                CareSection(title: "Overdue", items: sections.overdue, now: now,
                            completing: completing, onDone: complete, onSnooze: snooze)
                CareSection(title: "Today", items: sections.today, now: now,
                            completing: completing, onDone: complete, onSnooze: snooze)
                CareSection(title: "Coming up", items: sections.comingUp, now: now,
                            completing: completing, onDone: complete, onSnooze: snooze)
            }
            .scrollContentBackground(.hidden)
            .background(Theme.paper)
            .toolbarVisibility(.hidden, for: .navigationBar)
        }
        .onChange(of: scenePhase) {
            if scenePhase == .active { now = .now }
        }
        .sheet(item: $odometerRequest, content: OdometerSheet.init)
    }

    /// Shows the tick for a moment, then marks the item done and lets it leave the list.
    /// Items that repeat by distance ask for the odometer reading first.
    private func complete(_ item: CareItem) {
        if item.distance != nil {
            odometerRequest = OdometerRequest(item: item, purpose: .done)
            return
        }
        guard completing.insert(item.id).inserted else { return }
        Task {
            try? await Task.sleep(for: .milliseconds(450))
            withAnimation {
                item.markDone(now: .now)
                completing.remove(item.id)
            }
        }
    }

    private func snooze(_ item: CareItem) {
        withAnimation {
            item.snooze(now: .now)
        }
    }
}

#if DEBUG
#Preview {
    TodayView()
        .modelContainer(SampleData.previewContainer())
}
#endif
