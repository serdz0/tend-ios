import Foundation
import Testing
@testable import Tend

/// Today is 19 November 2026.
@MainActor
struct CareSummaryTests {
    private let calendar = TestCalendar.utc
    private let now = TestCalendar.date(2026, 11, 19, hour: 10)

    private func item(dueInDays days: Int) -> CareItem {
        let due = calendar.date(byAdding: .day, value: days, to: TestCalendar.date(2026, 11, 19))!
        return CareItem(name: "Monstera", kind: .plant, task: "Water",
                        recurrence: Recurrence(count: 7, unit: .day), dueDate: due)
    }

    private func summary(_ days: [Int]) -> CareSummary {
        CareSummary(items: days.map(item(dueInDays:)), now: now, calendar: calendar)
    }

    @Test func countsOverdueTodayAndTheNextSevenDays() {
        let summary = summary([-3, -1, 0, 1, 7, 8, 30])
        #expect(summary.overdue == 2)
        #expect(summary.today == 1)
        #expect(summary.thisWeek == 2)
    }

    @Test func needsAttentionIsOverduePlusToday() {
        #expect(summary([-2, 0, 0, 5]).needsAttention == 3)
    }

    @Test func aQuietWeekSaysSo() {
        #expect(summary([20]).headline == "Nothing needs you this week. Enjoy the calm.")
    }

    @Test func caughtUpButSomethingIsComing() {
        #expect(summary([2]).headline == "You're all caught up. One small thing is coming this week.")
        #expect(summary([2, 3, 4]).headline == "You're all caught up. 3 things are coming this week.")
    }

    @Test func oneThingNeedsYou() {
        #expect(summary([-1, 4]).headline == "One little thing needs you today.")
    }

    @Test func severalThingsNeedYou() {
        #expect(summary([-1, 0, 0]).headline == "3 things need you today.")
    }
}
