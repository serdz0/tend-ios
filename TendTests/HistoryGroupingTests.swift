import Foundation
import Testing
@testable import Tend

/// The History tab: entries grouped by day, newest first.
@MainActor
struct HistoryGroupingTests {
    private let calendar = TestCalendar.utc

    private func event(_ kind: CareEventKind, _ day: Int, hour: Int) -> CareEvent {
        CareEvent(date: TestCalendar.date(2026, 11, day, hour: hour), kind: kind)
    }

    @Test func noEventsMeansNoGroups() {
        #expect(HistoryDay.groups(from: [], calendar: calendar).isEmpty)
    }

    @Test func eventsAreGroupedByDayNewestDayFirst() {
        let monday = event(.done, 16, hour: 9)
        let tuesdayMorning = event(.snoozed, 17, hour: 8)
        let tuesdayEvening = event(.done, 17, hour: 20)

        let groups = HistoryDay.groups(from: [monday, tuesdayMorning, tuesdayEvening], calendar: calendar)

        #expect(groups.map(\.day) == [TestCalendar.date(2026, 11, 17), TestCalendar.date(2026, 11, 16)])
        #expect(groups.map { $0.events.count } == [2, 1])
    }

    @Test func eventsInsideADayAreNewestFirst() {
        let morning = event(.snoozed, 17, hour: 8)
        let evening = event(.done, 17, hour: 20)

        let groups = HistoryDay.groups(from: [morning, evening], calendar: calendar)

        #expect(groups.first?.events.map(\.kind) == [.done, .snoozed])
    }
}
