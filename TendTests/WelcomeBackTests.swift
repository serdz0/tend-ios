import Foundation
import Testing
@testable import Tend

/// Today is 19 November 2026.
@MainActor
struct WelcomeBackTests {
    private let calendar = TestCalendar.utc
    private let now = TestCalendar.date(2026, 11, 19, hour: 10)

    private func item(_ name: String, kind: ItemKind = .plant, task: String = "Water", dueInDays days: Int) -> CareItem {
        let due = calendar.date(byAdding: .day, value: days, to: TestCalendar.date(2026, 11, 19))!
        return CareItem(name: name, kind: kind, task: task,
                        recurrence: Recurrence(count: 7, unit: .day), dueDate: due)
    }

    private func welcome(away days: Int?, items: [CareItem]) -> WelcomeBack? {
        let last = days.map { calendar.date(byAdding: .day, value: -$0, to: now)! }
        return WelcomeBack(lastActive: last, items: items, now: now, calendar: calendar)
    }

    @Test func staysQuietWhenYouWereHereRecently() {
        #expect(welcome(away: 2, items: [item("Basil", dueInDays: -3)]) == nil)
    }

    @Test func staysQuietOnTheVeryFirstLaunch() {
        #expect(welcome(away: nil, items: [item("Basil", dueInDays: -3)]) == nil)
    }

    @Test func staysQuietWhenNothingIsWaiting() {
        #expect(welcome(away: 10, items: [item("Basil", dueInDays: 4)]) == nil)
    }

    @Test func welcomesYouBackAfterThreeDays() throws {
        let welcome = try #require(welcome(away: 3, items: [item("Basil", dueInDays: -2), item("Fern", dueInDays: 0)]))
        #expect(welcome.title == "Welcome back")
        #expect(welcome.message == "2 things are waiting. Nothing is wrong, and there's no rush.")
    }

    @Test func oneThingReadsNaturally() throws {
        let welcome = try #require(welcome(away: 5, items: [item("Basil", dueInDays: -1)]))
        #expect(welcome.message == "1 thing is waiting. Nothing is wrong, and there's no rush.")
    }

    @Test func suggestsOneEasyFirstStepPreferringPlants() throws {
        let car = item("Octavia", kind: .car, task: "Insurance", dueInDays: -9)
        let fern = item("Fern", dueInDays: -2)
        let welcome = try #require(welcome(away: 4, items: [car, fern]))
        #expect(welcome.firstStep === fern)
        #expect(welcome.suggestion == "A small place to start: Water Fern.")
    }

    @Test func fallsBackToTheMostOverdueWhenThereAreNoPlants() throws {
        let insurance = item("Octavia", kind: .car, task: "Insurance", dueInDays: -9)
        let tyres = item("Octavia", kind: .car, task: "Tyre swap", dueInDays: -1)
        let welcome = try #require(welcome(away: 4, items: [tyres, insurance]))
        #expect(welcome.firstStep === insurance)
    }
}
