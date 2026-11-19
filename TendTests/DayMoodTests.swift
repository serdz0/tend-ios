import Foundation
import Testing
@testable import Tend

/// The mascot's mood and the "Start here" pick. Today is 19 November 2026.
@MainActor
struct DayMoodTests {
    private let calendar = TestCalendar.utc
    private let now = TestCalendar.date(2026, 11, 19, hour: 10)

    private func plant(_ name: String, dueInDays days: Int) -> CareItem {
        let due = calendar.date(byAdding: .day, value: days, to: TestCalendar.date(2026, 11, 19))!
        return CareItem(name: name, kind: .plant, task: "Water",
                        recurrence: Recurrence(count: 7, unit: .day), dueDate: due)
    }

    private func oil(dueInDays days: Int) -> CareItem {
        let due = calendar.date(byAdding: .day, value: days, to: TestCalendar.date(2026, 11, 19))!
        let distance = DistanceSchedule(intervalKm: 15_000, lastServiceKm: 47_000, readingKm: 61_700,
                                        readingDate: TestCalendar.date(2026, 11, 19), kmPerYear: 12_000)
        return CareItem(name: "Car", kind: .car, task: "Oil service", schedule: .distance(distance), dueDate: due)
    }

    private func mood(_ items: [CareItem]) -> DayMood {
        DayMood(items: items, now: now, calendar: calendar)
    }

    // MARK: Mood

    @Test func nothingWaitingAndNothingDoneIsResting() {
        #expect(mood([plant("A", dueInDays: 3)]).kind == .resting)
    }

    @Test func anEmptyAppWavesHello() {
        #expect(mood([]).kind == .cheerful)
    }

    @Test func oneOrTwoWaitingIsCheerful() {
        #expect(mood([plant("A", dueInDays: 0)]).kind == .cheerful)
        #expect(mood([plant("A", dueInDays: -2), plant("B", dueInDays: 0)]).kind == .cheerful)
    }

    @Test func threeOrMoreWaitingIsEncouraging() {
        let items = [plant("A", dueInDays: -2), plant("B", dueInDays: 0), plant("C", dueInDays: 0)]
        #expect(mood(items).kind == .encouraging)
    }

    @Test func aBigPileIsStillEncouragingNeverSad() {
        let items = (1...9).map { plant("P\($0)", dueInDays: -$0) }
        #expect(mood(items).kind == .encouraging)
    }

    @Test func finishingEverythingTodayIsCelebrating() {
        let item = plant("A", dueInDays: 0)
        item.markDone(now: now, calendar: calendar)
        #expect(mood([item]).kind == .celebrating)
    }

    @Test func somethingDoneYesterdayDoesNotCelebrateToday() {
        let item = plant("A", dueInDays: 5)
        item.events.append(CareEvent(date: calendar.date(byAdding: .day, value: -1, to: now)!, kind: .done))
        #expect(mood([item]).kind == .resting)
    }

    @Test func aSnoozeDoesNotCountAsDone() {
        let item = plant("A", dueInDays: 5)
        item.events.append(CareEvent(date: now, kind: .snoozed))
        #expect(mood([item]).kind == .resting)
    }

    @Test func doneTodayButSomethingStillWaitingIsNotCelebrating() {
        let done = plant("A", dueInDays: 0)
        done.markDone(now: now, calendar: calendar)
        let waiting = plant("B", dueInDays: 0)
        #expect(mood([done, waiting]).kind == .cheerful)
    }

    @Test func everyMoodHasASentenceForVoiceOver() {
        for kind in [DayMood.Kind.celebrating, .resting, .cheerful, .encouraging] {
            #expect(!DayMood.sentence(for: kind).isEmpty)
        }
    }

    // MARK: Start here

    @Test func oneThingWaitingNeedsNoSuggestion() {
        #expect(StartHere.pick(from: [plant("A", dueInDays: 0)], now: now, calendar: calendar) == nil)
    }

    @Test func picksTheMostOverdueThing() {
        let late = plant("Late", dueInDays: -6)
        let items = [plant("Today", dueInDays: 0), late, plant("Recent", dueInDays: -1)]
        #expect(StartHere.pick(from: items, now: now, calendar: calendar) === late)
    }

    @Test func prefersAQuickTapOverSomethingThatNeedsTheOdometer() {
        let quick = plant("Quick", dueInDays: 0)
        let items = [oil(dueInDays: -4), quick]
        #expect(StartHere.pick(from: items, now: now, calendar: calendar) === quick)
    }

    @Test func fallsBackToTheOdometerTaskWhenThatIsAllThereIs() {
        let items = [oil(dueInDays: -4), oil(dueInDays: -2)]
        #expect(StartHere.pick(from: items, now: now, calendar: calendar) != nil)
    }

    @Test func thingsComingUpAreNeverPicked() {
        let items = [plant("A", dueInDays: 0), plant("B", dueInDays: 0), plant("Later", dueInDays: 4)]
        let pick = StartHere.pick(from: items, now: now, calendar: calendar)
        #expect(pick?.name != "Later")
    }

    @Test func tiesGoToTheNameThatComesFirst() {
        let a = plant("Alpha", dueInDays: 0)
        let b = plant("Beta", dueInDays: 0)
        #expect(StartHere.pick(from: [b, a], now: now, calendar: calendar) === a)
    }
}
