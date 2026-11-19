import Foundation
import Testing
@testable import Tend

/// What the calendar shows on each day. Today is 19 November 2026.
@MainActor
struct CalendarEntriesTests {
    private let calendar = TestCalendar.utc
    private let now = TestCalendar.date(2026, 11, 19, hour: 10)

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        TestCalendar.date(year, month, day)
    }

    private func entries(_ items: [CareItem], from start: Date, through end: Date) -> CalendarEntries {
        CalendarEntries(items: items, from: start, through: end, now: now, calendar: calendar)
    }

    private func weekly(due: Date, name: String = "Monstera") -> CareItem {
        CareItem(name: name, kind: .plant, task: "Water",
                 recurrence: Recurrence(count: 7, unit: .day), dueDate: due)
    }

    private func days(_ kind: CalendarEntry.Kind, in result: CalendarEntries, from start: Date, through end: Date) -> [Date] {
        var found: [Date] = []
        var day = start
        while day <= end {
            if result.entries(on: day).contains(where: { $0.kind == kind }) { found.append(day) }
            day = calendar.date(byAdding: .day, value: 1, to: day)!
        }
        return found
    }

    @Test func aDueDateShowsOnItsDay() {
        let result = entries([weekly(due: date(2026, 11, 20))], from: date(2026, 11, 1), through: date(2026, 11, 30))
        #expect(result.entries(on: date(2026, 11, 20)).map(\.kind) == [.due])
        #expect(result.entries(on: date(2026, 11, 21)).isEmpty)
    }

    @Test func repeatingItemsAreProjectedAssumingYouDoThemOnTime() {
        let result = entries([weekly(due: date(2026, 11, 20))], from: date(2026, 11, 1), through: date(2026, 12, 12))
        let expected = days(.expected, in: result, from: date(2026, 11, 1), through: date(2026, 12, 12))
        #expect(expected == [date(2026, 11, 27), date(2026, 12, 4), date(2026, 12, 11)])
    }

    @Test func anOverdueItemKeepsItsDayButProjectsFromToday() {
        // Due 15 November, so overdue. If you water it today, the next one is 26 November, not 22.
        let result = entries([weekly(due: date(2026, 11, 15))], from: date(2026, 11, 1), through: date(2026, 12, 5))
        #expect(result.entries(on: date(2026, 11, 15)).map(\.kind) == [.due])
        #expect(days(.expected, in: result, from: date(2026, 11, 1), through: date(2026, 12, 5)) == [date(2026, 11, 26), date(2026, 12, 3)])
    }

    @Test func yearlyTasksComeRoundOnTheSameDateEachYear() {
        let tyres = CareItem(name: "Car", kind: .car, task: "Fit summer tyres",
                             schedule: .yearly(month: 4, day: 1), dueDate: date(2027, 4, 1))
        let result = entries([tyres], from: date(2027, 1, 1), through: date(2029, 12, 31))
        #expect(result.entries(on: date(2027, 4, 1)).map(\.kind) == [.due])
        #expect(days(.expected, in: result, from: date(2027, 1, 1), through: date(2029, 12, 31)) == [date(2028, 4, 1), date(2029, 4, 1)])
    }

    @Test func distanceTasksAreProjectedByHowLongAServiceLasts() {
        // 100 km a day and 15,000 km between services: one service every 150 days.
        let oil = DistanceSchedule(intervalKm: 15_000, lastServiceKm: 47_000, readingKm: 61_000,
                                   readingDate: date(2026, 11, 19), kmPerYear: 36_500)
        let item = CareItem(name: "Car", kind: .car, task: "Oil service",
                            schedule: .distance(oil), dueDate: oil.dueDate(calendar: calendar))
        let result = entries([item], from: date(2026, 11, 1), through: date(2027, 6, 30))
        #expect(result.entries(on: date(2026, 11, 29)).map(\.kind) == [.due])
        #expect(days(.expected, in: result, from: date(2026, 11, 1), through: date(2027, 6, 30)) == [date(2027, 4, 28)])
    }

    @Test func pastDoneAndSnoozedEntriesShowOnTheirDay() {
        let item = weekly(due: date(2026, 11, 25))
        item.events.append(CareEvent(date: TestCalendar.date(2026, 11, 12, hour: 9, minute: 15), kind: .done))
        item.events.append(CareEvent(date: TestCalendar.date(2026, 11, 18, hour: 8), kind: .snoozed))
        let result = entries([item], from: date(2026, 11, 1), through: date(2026, 11, 30))
        #expect(result.entries(on: date(2026, 11, 12)).map(\.kind) == [.done])
        #expect(result.entries(on: date(2026, 11, 18)).map(\.kind) == [.snoozed])
    }

    @Test func nothingOutsideTheRequestedRangeIsIncluded() {
        let item = weekly(due: date(2026, 11, 20))
        item.events.append(CareEvent(date: TestCalendar.date(2026, 10, 30, hour: 9), kind: .done))
        let result = entries([item], from: date(2026, 11, 1), through: date(2026, 11, 30))
        #expect(result.entries(on: date(2026, 10, 30)).isEmpty)
        #expect(result.entries(on: date(2026, 12, 4)).isEmpty)
    }

    @Test func aDayListsWhatIsDueBeforeWhatIsExpectedAndWhatIsDone() {
        let due = weekly(due: date(2026, 11, 27), name: "Zebra plant")
        let expected = weekly(due: date(2026, 11, 20), name: "Aloe")
        let done = weekly(due: date(2026, 12, 4), name: "Basil")
        done.events.append(CareEvent(date: TestCalendar.date(2026, 11, 27, hour: 8), kind: .done))
        let result = entries([done, expected, due], from: date(2026, 11, 1), through: date(2026, 11, 30))
        #expect(result.entries(on: date(2026, 11, 27)).map(\.kind) == [.due, .expected, .done])
    }

    @Test func eachDayKnowsWhichGroupsAreOnIt() {
        let tyres = CareItem(name: "Car", kind: .car, task: "Fit winter tyres",
                             schedule: .yearly(month: 10, day: 31), dueDate: date(2026, 11, 20))
        let result = entries([weekly(due: date(2026, 11, 20)), tyres], from: date(2026, 11, 1), through: date(2026, 11, 30))
        #expect(result.categories(on: date(2026, 11, 20)) == [.plant, .tyres])
        #expect(result.categories(on: date(2026, 11, 21)).isEmpty)
    }
}
