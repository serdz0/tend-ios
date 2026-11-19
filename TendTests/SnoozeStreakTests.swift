import Foundation
import Testing
@testable import Tend

@MainActor
struct SnoozeStreakTests {
    private func item(_ kinds: [CareEventKind]) -> CareItem {
        let item = CareItem(name: "Basil", kind: .plant, task: "Water",
                            recurrence: Recurrence(count: 3, unit: .day), dueDate: TestCalendar.date(2026, 11, 19))
        for (index, kind) in kinds.enumerated() {
            item.events.append(CareEvent(date: TestCalendar.date(2026, 11, 1 + index), kind: kind))
        }
        return item
    }

    @Test func countsSnoozesInARow() {
        #expect(item([.snoozed, .snoozed]).snoozeStreak == 2)
    }

    @Test func doneStartsTheCountAgain() {
        #expect(item([.snoozed, .snoozed, .done, .snoozed]).snoozeStreak == 1)
        #expect(item([.snoozed, .snoozed, .done]).snoozeStreak == 0)
    }

    @Test func noHistoryMeansNoStreak() {
        #expect(item([]).snoozeStreak == 0)
    }

    @Test func countsFromTheNewestEvenIfStoredOutOfOrder() {
        let basil = item([])
        basil.events.append(CareEvent(date: TestCalendar.date(2026, 11, 10), kind: .snoozed))
        basil.events.append(CareEvent(date: TestCalendar.date(2026, 11, 5), kind: .done))
        basil.events.append(CareEvent(date: TestCalendar.date(2026, 11, 12), kind: .snoozed))
        #expect(basil.snoozeStreak == 2)
    }

    @Test func asksAfterEveryThirdSnooze() {
        #expect(item([.snoozed, .snoozed]).needsSnoozeCheckIn == false)
        #expect(item([.snoozed, .snoozed, .snoozed]).needsSnoozeCheckIn == true)
        #expect(item([.snoozed, .snoozed, .snoozed, .snoozed]).needsSnoozeCheckIn == false)
        #expect(item([.snoozed, .snoozed, .snoozed, .snoozed, .snoozed, .snoozed]).needsSnoozeCheckIn == true)
    }
}
