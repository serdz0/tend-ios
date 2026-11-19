import Foundation
import Testing
@testable import Tend

/// November 2026 starts on a Sunday and has 30 days.
struct CalendarMonthTests {
    private func calendar(firstWeekday: Int) -> Calendar {
        var calendar = TestCalendar.utc
        calendar.firstWeekday = firstWeekday
        return calendar
    }

    @Test func sundayFirstNeedsNoLeadingBlanks() {
        let month = CalendarMonth(containing: TestCalendar.date(2026, 11, 19), calendar: calendar(firstWeekday: 1))
        #expect(month.cells.count == 35)
        #expect(month.cells.first! == TestCalendar.date(2026, 11, 1))
        #expect(month.cells[29] == TestCalendar.date(2026, 11, 30))
        #expect(month.cells[30...].allSatisfy { $0 == nil })
    }

    @Test func mondayFirstLeavesSixBlanksBeforeASunday() {
        let month = CalendarMonth(containing: TestCalendar.date(2026, 11, 19), calendar: calendar(firstWeekday: 2))
        #expect(month.cells[..<6].allSatisfy { $0 == nil })
        #expect(month.cells[6] == TestCalendar.date(2026, 11, 1))
        #expect(month.cells.count == 42)
    }

    @Test func gridAlwaysFillsWholeWeeks() {
        let month = CalendarMonth(containing: TestCalendar.date(2026, 2, 10), calendar: calendar(firstWeekday: 2))
        #expect(month.cells.count % 7 == 0)
        #expect(month.cells.compactMap { $0 }.count == 28)
    }

    @Test func weekdayNamesStartOnTheFirstWeekday() {
        let calendar = calendar(firstWeekday: 2)
        let month = CalendarMonth(containing: TestCalendar.date(2026, 11, 19), calendar: calendar)
        #expect(month.weekdaySymbols.count == 7)
        #expect(month.weekdaySymbols.first == calendar.shortWeekdaySymbols[1])
        #expect(month.weekdaySymbols.last == calendar.shortWeekdaySymbols[0])
    }

    @Test func shiftingMovesWholeMonthsAcrossTheYearEnd() {
        let month = CalendarMonth(containing: TestCalendar.date(2026, 11, 19), calendar: calendar(firstWeekday: 1))
        #expect(month.shifted(by: 2).start == TestCalendar.date(2027, 1, 1))
        #expect(month.shifted(by: -11).start == TestCalendar.date(2025, 12, 1))
    }

    @Test func containsOnlyDaysOfThatMonth() {
        let month = CalendarMonth(containing: TestCalendar.date(2026, 11, 19), calendar: calendar(firstWeekday: 1))
        #expect(month.contains(TestCalendar.date(2026, 11, 30, hour: 23)))
        #expect(!month.contains(TestCalendar.date(2026, 12, 1)))
    }
}
