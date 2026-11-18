import Foundation
import Testing
@testable import Tend

/// Fixed calendar and dates so the tests give the same result on any day.
@MainActor
struct CareScheduleTests {
    private let calendar: Calendar = {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 12) -> Date {
        calendar.date(from: DateComponents(year: year, month: month, day: day, hour: hour))!
    }

    private func item(
        _ name: String = "Monstera",
        kind: ItemKind = .plant,
        task: String = "Water",
        every recurrence: Recurrence = Recurrence(count: 7, unit: .day),
        due: Date
    ) -> CareItem {
        CareItem(name: name, kind: kind, task: task, recurrence: recurrence, dueDate: due)
    }

    // MARK: Recurrence

    @Test func recurrenceAddsDays() {
        let next = Recurrence(count: 7, unit: .day).next(after: date(2026, 11, 19), calendar: calendar)
        #expect(next == date(2026, 11, 26))
    }

    @Test func recurrenceAddsMonthsAcrossYearEnd() {
        let next = Recurrence(count: 6, unit: .month).next(after: date(2026, 11, 19), calendar: calendar)
        #expect(next == date(2027, 5, 19))
    }

    @Test func recurrenceAddsYears() {
        let next = Recurrence(count: 2, unit: .year).next(after: date(2026, 11, 19), calendar: calendar)
        #expect(next == date(2028, 11, 19))
    }

    // MARK: Status

    @Test func dueYesterdayIsOneDayOverdue() {
        let monstera = item(due: date(2026, 11, 18, hour: 9))
        #expect(monstera.status(now: date(2026, 11, 19, hour: 8), calendar: calendar) == .overdue(days: 1))
    }

    @Test func dueEarlierTodayIsNotOverdue() {
        let monstera = item(due: date(2026, 11, 19, hour: 6))
        #expect(monstera.status(now: date(2026, 11, 19, hour: 22), calendar: calendar) == .dueToday)
    }

    @Test func dueInTwelveDaysIsUpcoming() {
        let tyres = item(due: date(2026, 12, 1, hour: 9))
        #expect(tyres.status(now: date(2026, 11, 19, hour: 22), calendar: calendar) == .upcoming(days: 12))
    }

    // MARK: Mark done and snooze

    @Test func markingDoneCountsFromToday() {
        let monstera = item(due: date(2026, 11, 16))
        monstera.markDone(now: date(2026, 11, 19, hour: 10), calendar: calendar)
        #expect(calendar.startOfDay(for: monstera.dueDate) == date(2026, 11, 26, hour: 0))
        #expect(monstera.status(now: date(2026, 11, 19, hour: 10), calendar: calendar) == .upcoming(days: 7))
    }

    @Test func markingDoneRecordsHistory() {
        let monstera = item(due: date(2026, 11, 18))
        monstera.markDone(now: date(2026, 11, 19, hour: 10), calendar: calendar)
        #expect(monstera.events.count == 1)
        #expect(monstera.events.first?.kind == .done)
        #expect(monstera.events.first?.date == date(2026, 11, 19, hour: 10))
    }

    @Test func snoozingMovesDueDateToTomorrowAndRecordsIt() {
        let monstera = item(due: date(2026, 11, 17))
        monstera.snooze(now: date(2026, 11, 19, hour: 10), calendar: calendar)
        #expect(monstera.status(now: date(2026, 11, 19, hour: 10), calendar: calendar) == .upcoming(days: 1))
        #expect(monstera.events.first?.kind == .snoozed)
    }

    // MARK: Today sections

    @Test func sectionsSplitIntoOverdueTodayAndComingUp() {
        let now = date(2026, 11, 19, hour: 8)
        let stk = item("Car", kind: .car, task: "STK inspection", due: date(2026, 11, 16))
        let monstera = item("Monstera", due: date(2026, 11, 18))
        let fig = item("Fiddle leaf fig", due: date(2026, 11, 19))
        let tyres = item("Car", kind: .car, task: "Winter tyre swap", due: date(2026, 12, 1))

        let sections = TodaySections(items: [tyres, fig, monstera, stk], now: now, calendar: calendar)

        #expect(sections.overdue.map(\.title) == ["STK inspection", "Water Monstera"])
        #expect(sections.today.map(\.title) == ["Water Fiddle leaf fig"])
        #expect(sections.comingUp.map(\.title) == ["Winter tyre swap"])
    }

    @Test func comingUpOnlyShowsTheNextThirtyDays() {
        let now = date(2026, 11, 19, hour: 8)
        let soon = item("Basil", due: date(2026, 12, 19))
        let later = item("Aloe", due: date(2026, 12, 20))

        let sections = TodaySections(items: [later, soon], now: now, calendar: calendar)

        #expect(sections.comingUp.map(\.title) == ["Water Basil"])
    }

    @Test func nothingDueMeansNothingToDo() {
        let now = date(2026, 11, 19, hour: 8)
        let sections = TodaySections(items: [item(due: date(2026, 12, 10))], now: now, calendar: calendar)
        #expect(sections.hasWork == false)
    }
}
