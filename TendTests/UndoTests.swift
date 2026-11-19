import Foundation
import Testing
@testable import Tend

/// Today is 19 November 2026.
@MainActor
struct UndoTests {
    private let calendar = TestCalendar.utc
    private let now = TestCalendar.date(2026, 11, 19, hour: 10)

    private func plant(dueInDays days: Int) -> CareItem {
        let due = calendar.date(byAdding: .day, value: days, to: TestCalendar.date(2026, 11, 19))!
        return CareItem(name: "Basil", kind: .plant, task: "Water",
                        recurrence: Recurrence(count: 3, unit: .day), dueDate: due)
    }

    @Test func undoingDoneBringsBackTheOldDueDateAndRemovesTheHistoryLine() {
        let basil = plant(dueInDays: -2)
        let oldDue = basil.dueDate

        let undo = basil.markDone(now: now, calendar: calendar)
        #expect(basil.dueDate != oldDue)
        #expect(basil.events.count == 1)

        undo.apply()
        #expect(basil.dueDate == oldDue)
        #expect(basil.events.isEmpty)
    }

    @Test func undoingSnoozeBringsBackTheOldDueDate() {
        let basil = plant(dueInDays: 0)
        let oldDue = basil.dueDate

        let undo = basil.snooze(now: now, calendar: calendar)
        #expect(basil.dueDate > oldDue)

        undo.apply()
        #expect(basil.dueDate == oldDue)
        #expect(basil.events.isEmpty)
    }

    @Test func undoingDoneOnADistanceItemBringsBackTheOldReading() throws {
        let schedule = DistanceSchedule(intervalKm: 15_000, lastServiceKm: 47_000, readingKm: 61_000,
                                        readingDate: TestCalendar.date(2026, 11, 1), kmPerYear: 12_000)
        let oil = CareItem(name: "Octavia", kind: .car, task: "Oil service", schedule: .distance(schedule),
                           dueDate: TestCalendar.date(2026, 11, 20))

        let undo = oil.markDone(now: now, odometerKm: 62_500, calendar: calendar)
        #expect(oil.distance?.lastServiceKm == 62_500)

        undo.apply()
        #expect(oil.distance == schedule)
        #expect(oil.dueDate == TestCalendar.date(2026, 11, 20))
    }

    @Test func undoOnlyRemovesTheEventItMade() {
        let basil = plant(dueInDays: 0)
        basil.snooze(now: TestCalendar.date(2026, 11, 18), calendar: calendar)
        let undo = basil.markDone(now: now, calendar: calendar)
        #expect(basil.events.count == 2)

        undo.apply()
        #expect(basil.events.map(\.kind) == [.snoozed])
    }

    @Test func messagesNameTheItem() {
        let basil = plant(dueInDays: 0)
        #expect(basil.markDone(now: now, calendar: calendar).message == "Water Basil is done.")
        #expect(basil.snooze(now: now, calendar: calendar).message == "Water Basil is snoozed until tomorrow.")
    }
}
