import Foundation
import Testing
@testable import Tend

/// Today is 19 November 2026.
@MainActor
struct FreshStartTests {
    private let calendar = TestCalendar.utc
    private let now = TestCalendar.date(2026, 11, 19, hour: 10)

    private func plant(_ name: String, dueInDays days: Int) -> CareItem {
        let due = calendar.date(byAdding: .day, value: days, to: TestCalendar.date(2026, 11, 19))!
        return CareItem(name: name, kind: .plant, task: "Water",
                        recurrence: Recurrence(count: 7, unit: .day), dueDate: due)
    }

    private func day(_ offset: Int) -> Date {
        calendar.date(byAdding: .day, value: offset, to: TestCalendar.date(2026, 11, 19))!
    }

    @Test func spreadsTheOverdueItemsTwoADayStartingToday() {
        let items = [plant("A", dueInDays: -5), plant("B", dueInDays: -4), plant("C", dueInDays: -3),
                     plant("D", dueInDays: -2), plant("E", dueInDays: -1)]
        let freshStart = FreshStart(items: items, now: now, calendar: calendar)

        freshStart.apply()
        #expect(items.map(\.dueDate) == [day(0), day(0), day(1), day(1), day(2)])
    }

    @Test func theMostOverdueGoFirst() {
        let late = plant("Late", dueInDays: -9)
        let recent = plant("Recent", dueInDays: -1)
        let freshStart = FreshStart(items: [recent, late], now: now, calendar: calendar)

        #expect(freshStart.moves.map(\.item.name) == ["Late", "Recent"])
    }

    @Test func thingsAlreadyDueTodayTakeUpRoom() {
        let items = [plant("A", dueInDays: -3), plant("B", dueInDays: -2), plant("Today", dueInDays: 0)]
        let freshStart = FreshStart(items: items, now: now, calendar: calendar)

        freshStart.apply()
        #expect(items[0].dueDate == day(0))
        #expect(items[1].dueDate == day(1))
    }

    @Test func carDeadlinesStayWhereTheyAre() {
        let stk = CareItem(name: "Octavia", kind: .car, task: "STK inspection",
                           schedule: .yearly(month: 11, day: 1), dueDate: day(-18))
        let oil = CareItem(name: "Octavia", kind: .car, task: "Oil service",
                           schedule: .distance(DistanceSchedule(intervalKm: 15_000, lastServiceKm: 40_000,
                                                                 readingKm: 56_000, readingDate: day(-30),
                                                                 kmPerYear: 12_000)),
                           dueDate: day(-3))
        let insurance = CareItem(name: "Octavia", kind: .car, task: "Insurance",
                                 recurrence: Recurrence(count: 1, unit: .year), dueDate: day(-6))
        let freshStart = FreshStart(items: [stk, oil, insurance, plant("A", dueInDays: -2)], now: now, calendar: calendar)

        #expect(freshStart.moves.map(\.item.name) == ["A"])
    }

    @Test func offeredOnlyWhenThreeOrMoreCanMove() {
        let two = [plant("A", dueInDays: -2), plant("B", dueInDays: -1)]
        let three = two + [plant("C", dueInDays: -4)]
        #expect(FreshStart(items: two, now: now, calendar: calendar).isWorthOffering == false)
        #expect(FreshStart(items: three, now: now, calendar: calendar).isWorthOffering == true)
    }

    @Test func nothingOverdueMeansNothingToMove() {
        let freshStart = FreshStart(items: [plant("A", dueInDays: 0), plant("B", dueInDays: 3)],
                                    now: now, calendar: calendar)
        #expect(freshStart.moves.isEmpty)
    }

    @Test func canBeUndone() {
        let items = [plant("A", dueInDays: -5), plant("B", dueInDays: -4), plant("C", dueInDays: -3)]
        let before = items.map(\.dueDate)
        let undo = FreshStart(items: items, now: now, calendar: calendar).apply()

        #expect(undo.message == "Spread 3 plants over 2 days.")
        undo.apply()
        #expect(items.map(\.dueDate) == before)
    }
}
