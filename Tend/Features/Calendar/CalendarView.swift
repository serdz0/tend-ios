import SwiftData
import SwiftUI

/// A month at a glance, a summary of what needs doing, and the plan for the day you pick.
struct CalendarView: View {
    @Query private var items: [CareItem]
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.dynamicTypeSize) private var dynamicTypeSize
    @State private var now = Date.now
    @State private var month = CalendarMonth(containing: .now)
    @State private var selectedDay = Calendar.current.startOfDay(for: .now)

    var body: some View {
        let calendar = Calendar.current
        let days = month.cells.compactMap { $0 }
        let entries = CalendarEntries(
            items: items,
            from: month.start,
            through: days.last ?? month.start,
            now: now
        )

        NavigationStack {
            List {
                CalendarHeader(
                    month: month,
                    showsTodayButton: !month.contains(now) || !calendar.isDate(selectedDay, inSameDayAs: now),
                    onPrevious: showPreviousMonth,
                    onNext: showNextMonth,
                    onToday: goToToday
                )
                .listRowBackground(Color.clear)
                .listRowSeparator(.hidden)

                if !dynamicTypeSize.isAccessibilitySize {
                    Section {
                        CalendarGrid(month: month, selectedDay: selectedDay, now: now,
                                     entries: entries, onSelect: select)
                    }
                    .listRowBackground(Theme.card)
                    .listRowInsets(EdgeInsets(top: Theme.Spacing.s, leading: Theme.Spacing.s,
                                              bottom: Theme.Spacing.s, trailing: Theme.Spacing.s))
                }

                Section {
                    CalendarSummaryStrip(summary: CareSummary(items: items, now: now))
                }
                .listRowBackground(Theme.card)

                if dynamicTypeSize.isAccessibilitySize {
                    // At very large text sizes a grid is too cramped, so list the days that have something on.
                    ForEach(days.filter { !entries.entries(on: $0).isEmpty }, id: \.self) { day in
                        CalendarDaySection(day: day, entries: entries.entries(on: day), now: now)
                    }
                } else {
                    CalendarDaySection(day: selectedDay, entries: entries.entries(on: selectedDay), now: now)
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
    }

    private func select(_ day: Date) {
        selectedDay = day
    }

    private func showPreviousMonth() {
        move(by: -1)
    }

    private func showNextMonth() {
        move(by: 1)
    }

    private func move(by months: Int) {
        month = month.shifted(by: months)
        selectedDay = month.contains(now) ? Calendar.current.startOfDay(for: now) : month.start
    }

    private func goToToday() {
        month = CalendarMonth(containing: now)
        selectedDay = Calendar.current.startOfDay(for: now)
    }
}

#if DEBUG
#Preview {
    CalendarView()
        .modelContainer(SampleData.previewContainer())
}
#endif
