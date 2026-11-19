import SwiftData
import SwiftUI

struct TodayView: View {
    @Query(sort: \CareItem.dueDate) private var items: [CareItem]
    @Environment(\.scenePhase) private var scenePhase
    @Environment(ReminderCenter.self) private var reminders
    @State private var now = Date.now
    /// Items whose tick is showing for a moment before they leave the list.
    @State private var completing: Set<UUID> = []
    /// Set when an item that repeats by distance is marked done: it needs an odometer reading first.
    @State private var odometerRequest: OdometerRequest?

    var body: some View {
        let sections = TodaySections(items: items, now: now)
        let summary = CareSummary(items: items, now: now)

        NavigationStack {
            List {
                TodayHeader(now: now, summary: summary)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                if reminders.status == .notDetermined {
                    Section {
                        ReminderPromptCard()
                    }
                    .listRowBackground(Theme.card)
                }

                if !sections.hasWork {
                    ContentUnavailableView(
                        "You're all caught up",
                        systemImage: "sun.max",
                        description: Text("Your plants and your car are happy. Go and enjoy the day.")
                    )
                    .listRowBackground(Color.clear)
                }

                CareSection(title: "Waiting for you", items: sections.overdue, now: now,
                            completing: completing, onDone: complete, onSnooze: snooze)
                CareSection(title: "For today", items: sections.today, now: now,
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
        // A reminder's Done button for a task that repeats by distance lands here to ask for the odometer.
        .task(id: reminders.itemToFinish) {
            openOdometerForReminder()
        }
    }

    private func openOdometerForReminder() {
        guard let id = reminders.itemToFinish else { return }
        reminders.itemToFinish = nil
        guard let item = items.first(where: { $0.id == id }) else { return }
        odometerRequest = OdometerRequest(item: item, purpose: .done)
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
        .environment(ReminderCenter())
}
#endif
