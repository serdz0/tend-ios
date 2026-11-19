import Foundation
import Testing
@testable import Tend

/// Now is Thursday 19 November 2026, 08:00. The morning note arrives at 10:30 by default.
@MainActor
struct DigestPlannerTests {
    private let calendar = TestCalendar.utc
    private let now = TestCalendar.date(2026, 11, 19, hour: 8)

    private func date(_ day: Int, hour: Int = 0, minute: Int = 0) -> Date {
        TestCalendar.date(2026, 11, day, hour: hour, minute: minute)
    }

    private func item(_ name: String = "Monstera", task: String = "Water", kind: ItemKind = .plant, due day: Int) -> CareItem {
        CareItem(name: name, kind: kind, task: task,
                 schedule: .interval(Recurrence(count: 7, unit: .day)), dueDate: date(day))
    }

    private func plans(_ items: [CareItem], settings: ReminderSettings = ReminderSettings(), at time: Date? = nil) -> [ReminderPlan] {
        ReminderPlanner.plans(for: items, settings: settings, now: time ?? now, calendar: calendar)
    }

    @Test func oneNotePerDayForTheNextThreeDays() {
        let result = plans([item(due: 10)])
        #expect(result.map(\.fireDate) == [date(19, hour: 10, minute: 30), date(20, hour: 10, minute: 30), date(21, hour: 10, minute: 30)])
        #expect(result.map(\.identifier) == ["care-digest-2026-11-19", "care-digest-2026-11-20", "care-digest-2026-11-21"])
    }

    @Test func aDigestBelongsToNoSingleItem() {
        let result = plans([item(due: 19)])
        #expect(result.allSatisfy { $0.itemID == nil })
        #expect(result.allSatisfy { !$0.needsOdometer })
    }

    @Test func noNoteWhenNothingIsWaiting() {
        #expect(plans([item(due: 40)]).isEmpty)
        #expect(plans([]).isEmpty)
    }

    @Test func aThingJoinsTheNoteOnItsDueDay() {
        let result = plans([item(due: 21)])
        #expect(result.map(\.fireDate) == [date(21, hour: 10, minute: 30)])
    }

    @Test func overdueThingsStayOnTheList() {
        let result = plans([item(due: 15)])
        #expect(result.count == 3)
    }

    @Test func todaysNoteIsSkippedOnceItsTimeHasPassed() {
        let result = plans([item(due: 15)], at: date(19, hour: 11))
        #expect(result.map(\.fireDate) == [date(20, hour: 10, minute: 30), date(21, hour: 10, minute: 30), date(22, hour: 10, minute: 30)])
    }

    @Test func usesTheChosenTime() {
        var settings = ReminderSettings()
        settings.digestTime = TimeOfDay(hour: 8, minute: 15)
        let result = plans([item(due: 15)], settings: settings, at: date(19, hour: 7))
        #expect(result.first?.fireDate == date(19, hour: 8, minute: 15))
    }

    @Test func quietDaysGetNoNote() {
        var settings = ReminderSettings()
        settings.pause(forDays: 2, from: now, calendar: calendar)
        let result = plans([item(due: 15)], settings: settings)
        #expect(result.map(\.fireDate) == [date(21, hour: 10, minute: 30), date(22, hour: 10, minute: 30), date(23, hour: 10, minute: 30)])
    }

    @Test func theTitleIsAGreeting() {
        #expect(plans([item(due: 19)]).first?.title == "Good morning")
    }

    // MARK: Wording

    @Test func listsUpToThreeThingsByName() {
        let body = ReminderPlanner.digestBody(titles: ["Water Basil", "Water Fern", "STK inspection"], variant: 0)
        #expect(body == "3 things are waiting for you: Water Basil, Water Fern and STK inspection.")
    }

    @Test func oneThingReadsNaturally() {
        #expect(ReminderPlanner.digestBody(titles: ["Water Basil"], variant: 0) == "One thing is waiting for you: Water Basil.")
    }

    @Test func longerListsEndWithHowManyMore() {
        let body = ReminderPlanner.digestBody(titles: ["A", "B", "C", "D", "E"], variant: 0)
        #expect(body == "5 things are waiting for you: A, B, C and 2 more.")
    }

    @Test func theWordingChangesFromDayToDay() {
        let titles = ["Water Basil", "Water Fern"]
        let bodies = Set((0..<3).map { ReminderPlanner.digestBody(titles: titles, variant: $0) })
        #expect(bodies.count == 3)
        #expect(ReminderPlanner.digestBody(titles: titles, variant: 3) == ReminderPlanner.digestBody(titles: titles, variant: 0))
    }

    @Test func noWordingScolds() {
        let words = ["late", "behind", "forgot", "missed", "should", "must", "failed"]
        for variant in 0..<3 {
            let body = ReminderPlanner.digestBody(titles: ["Water Basil", "Water Fern"], variant: variant).lowercased()
            #expect(words.allSatisfy { !body.contains($0) })
        }
    }

    // MARK: One note per thing

    @Test func theOldStyleStillGivesOneReminderPerThing() {
        var settings = ReminderSettings()
        settings.style = .perItem
        let result = plans([item(due: 20), item("Fern", due: 22)], settings: settings)
        #expect(result.count == 2)
        #expect(result.allSatisfy { $0.itemID != nil })
    }

    @Test func quietDaysAlsoSilenceTheOldStyle() {
        var settings = ReminderSettings()
        settings.style = .perItem
        settings.pause(forDays: 2, from: now, calendar: calendar)
        let result = plans([item(due: 20), item("Fern", due: 22)], settings: settings)
        #expect(result.map(\.fireDate) == [date(22, hour: 10, minute: 30)])
    }

    @Test func perThingWordingVariesToo() {
        let first = ReminderPlanner.plan(for: item(due: 20), now: now, calendar: calendar)
        let second = ReminderPlanner.plan(for: item(due: 21), now: now, calendar: calendar)
        #expect(first?.body != second?.body)
    }
}
