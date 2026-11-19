import SwiftData
import SwiftUI

struct TodayView: View {
    @Query(sort: \CareItem.dueDate) private var items: [CareItem]
    @Environment(\.scenePhase) private var scenePhase
    @Environment(ReminderCenter.self) private var reminders
    @Environment(ReminderSettingsStore.self) private var reminderSettings
    @State private var now = Date.now
    /// Items whose tick is showing for a moment before they leave the list.
    @State private var completing: Set<UUID> = []
    /// Set when an item that repeats by distance is marked done: it needs an odometer reading first.
    @State private var odometerRequest: OdometerRequest?
    /// The last thing done, snoozed or spread out, which can still be taken back.
    @State private var undo: CareUndo?
    @State private var welcome: WelcomeBack?
    @State private var catchUpDismissed = false
    /// When the app was last in use, as seconds since 1970. Zero means never.
    @AppStorage("lastActive") private var lastActive: Double = 0
    /// Becomes true after the first thing is added or finished. Reminders are only offered after that.
    @AppStorage("firstSuccess") private var firstSuccess = false
    @State private var snoozeCheck: CareItem?
    @State private var editing: CareItem?
    @State private var showsReminderSettings = false

    var body: some View {
        let sections = TodaySections(items: items, now: now)
        let summary = CareSummary(items: items, now: now)
        let freshStart = FreshStart(items: items, now: now)
        let showsFreshStart = freshStart.isWorthOffering

        NavigationStack {
            List {
                TodayHeader(now: now, summary: summary)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)

                if let snoozeCheck {
                    Section {
                        SnoozeCheckCard(
                            item: snoozeCheck,
                            onChange: { changeSchedule(of: snoozeCheck) },
                            onDismiss: dismissSnoozeCheck,
                            onNeverAsk: stopSnoozeCheckIns
                        )
                    }
                    .listRowBackground(Theme.card)
                }

                if !catchUpDismissed, welcome != nil || showsFreshStart {
                    Section {
                        CatchUpCard(
                            welcome: welcome,
                            freshStart: showsFreshStart ? freshStart : nil,
                            onFreshStart: { spreadOut(freshStart) },
                            onDismiss: dismissCatchUp
                        )
                    }
                    .listRowBackground(Theme.card)
                }

                if reminders.status == .notDetermined, firstSuccess {
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

                Section {
                    ReminderSettingsRow(settings: reminderSettings.settings, now: now, onOpen: openReminderSettings)
                }
                .listRowBackground(Theme.card)
            }
            .scrollContentBackground(.hidden)
            .background(Theme.paper)
            .toolbarVisibility(.hidden, for: .navigationBar)
            // Inside the stack, so the list scrolls clear of the bar instead of hiding behind it.
            .safeAreaInset(edge: .bottom) {
                if let undo {
                    UndoBar(message: undo.message, onUndo: undoLast, onClose: closeUndo)
                        .transition(.opacity)
                }
            }
        }
        .onChange(of: scenePhase) {
            switch scenePhase {
            case .active:
                now = .now
                checkWelcome()
            case .background:
                lastActive = Date.now.timeIntervalSince1970
            default:
                break
            }
        }
        .onAppear(perform: checkWelcome)
        // Adding or removing things makes an old undo unsafe, so it goes away.
        .onChange(of: items.count) { undo = nil }
        .sheet(item: $odometerRequest, content: OdometerSheet.init)
        .sheet(item: $editing) { ItemFormView(editing: $0) }
        .sheet(isPresented: $showsReminderSettings) { ReminderSettingsView() }
        // A reminder's Done button for a task that repeats by distance lands here to ask for the odometer.
        .task(id: reminders.itemToFinish) {
            openOdometerForReminder()
        }
    }

    private func openOdometerForReminder() {
        guard let id = reminders.itemToFinish else { return }
        reminders.itemToFinish = nil
        guard let item = items.first(where: { $0.id == id }) else { return }
        odometerRequest = OdometerRequest(item: item, purpose: .done, onMarkedDone: offerUndo)
    }

    /// Says hello after a few days away, once per visit. The time of this visit is saved for next time.
    private func checkWelcome() {
        if welcome == nil {
            let last = lastActive > 0 ? Date(timeIntervalSince1970: lastActive) : nil
            welcome = WelcomeBack(lastActive: last, items: items, now: now)
            catchUpDismissed = false
        }
        lastActive = Date.now.timeIntervalSince1970
    }

    private func dismissCatchUp() {
        withAnimation { catchUpDismissed = true }
    }

    private func spreadOut(_ freshStart: FreshStart) {
        withAnimation {
            let newUndo = freshStart.apply()
            undo = newUndo
            welcome = nil
        }
    }

    private func offerUndo(_ newUndo: CareUndo) {
        firstSuccess = true
        withAnimation { undo = newUndo }
    }

    private func undoLast() {
        withAnimation {
            undo?.apply()
            undo = nil
            snoozeCheck = nil
        }
    }

    private func openReminderSettings() {
        showsReminderSettings = true
    }

    private func changeSchedule(of item: CareItem) {
        snoozeCheck = nil
        editing = item
    }

    private func dismissSnoozeCheck() {
        withAnimation { snoozeCheck = nil }
    }

    private func stopSnoozeCheckIns() {
        reminderSettings.settings.snoozeCheckIn = false
        dismissSnoozeCheck()
    }

    private func closeUndo() {
        withAnimation { undo = nil }
    }

    /// Shows the tick for a moment, then marks the item done and lets it leave the list.
    /// Items that repeat by distance ask for the odometer reading first.
    private func complete(_ item: CareItem) {
        if item.distance != nil {
            odometerRequest = OdometerRequest(item: item, purpose: .done, onMarkedDone: offerUndo)
            return
        }
        guard completing.insert(item.id).inserted else { return }
        Task {
            try? await Task.sleep(for: .milliseconds(450))
            withAnimation {
                undo = item.markDone(now: .now)
                firstSuccess = true
                completing.remove(item.id)
            }
        }
    }

    private func snooze(_ item: CareItem) {
        withAnimation {
            undo = item.snooze(now: .now)
            if reminderSettings.settings.snoozeCheckIn, item.needsSnoozeCheckIn {
                snoozeCheck = item
            }
        }
    }
}

#if DEBUG
#Preview {
    TodayView()
        .modelContainer(SampleData.previewContainer())
        .environment(ReminderCenter())
        .environment(ReminderSettingsStore())
}
#endif
