import Foundation
import Testing
@testable import Tend

/// One reminder per item, on its due day at its reminder time. Now is 19 November 2026, 08:00.
@MainActor
struct ReminderPlannerTests {
    private let calendar = TestCalendar.utc
    private let now = TestCalendar.date(2026, 11, 19, hour: 8)

    private func date(_ day: Int, hour: Int = 0, minute: Int = 0) -> Date {
        TestCalendar.date(2026, 11, day, hour: hour, minute: minute)
    }

    private func plant(due day: Int, at time: TimeOfDay = .defaultReminder) -> CareItem {
        CareItem(name: "Monstera", kind: .plant, task: "Water",
                 schedule: .interval(Recurrence(count: 7, unit: .day)),
                 dueDate: date(day), plantType: .monstera, reminderTime: time)
    }

    private func plan(for item: CareItem, at now: Date? = nil) -> ReminderPlan? {
        ReminderPlanner.plan(for: item, now: now ?? self.now, calendar: calendar)
    }

    @Test func remindsOnTheDueDayAtTenThirtyByDefault() {
        #expect(plan(for: plant(due: 20))?.fireDate == date(20, hour: 10, minute: 30))
    }

    @Test func usesTheItemsOwnReminderTime() {
        let item = plant(due: 20, at: TimeOfDay(hour: 7, minute: 15))
        #expect(plan(for: item)?.fireDate == date(20, hour: 7, minute: 15))
    }

    @Test func dueTodayStillRemindsIfTheTimeHasNotPassed() {
        #expect(plan(for: plant(due: 19))?.fireDate == date(19, hour: 10, minute: 30))
    }

    @Test func dueTodayAfterTheReminderTimeGetsNoReminder() {
        #expect(plan(for: plant(due: 19), at: date(19, hour: 11)) == nil)
    }

    @Test func overdueItemsGetNoReminder() {
        #expect(plan(for: plant(due: 15)) == nil)
    }

    @Test func plantReminderIsWarm() {
        let result = plan(for: plant(due: 20))
        #expect(result?.title == "Water Monstera")
        #expect(result?.body == "Your Monstera would love a drink today.")
    }

    @Test func carReminderIsWarm() {
        let car = CareItem(name: "Car", kind: .car, task: "STK inspection",
                           recurrence: Recurrence(count: 2, unit: .year), dueDate: date(20))
        let result = plan(for: car)
        #expect(result?.title == "STK inspection")
        #expect(result?.body == "STK inspection is due today. A quick tick and you're set.")
        #expect(result?.needsOdometer == false)
    }

    @Test func distanceTasksAskForAnOdometerReading() {
        let schedule = DistanceSchedule(intervalKm: 15_000, lastServiceKm: 47_000, readingKm: 61_700,
                                        readingDate: date(19), kmPerYear: 36_500)
        let oil = CareItem(name: "Car", kind: .car, task: "Oil service",
                           schedule: .distance(schedule), dueDate: date(22))
        let result = plan(for: oil)
        #expect(result?.needsOdometer == true)
        #expect(result?.body == "Oil service is due around now. Got a fresh odometer reading?")
    }

    @Test func eachPlanKnowsItsItem() {
        let item = plant(due: 20)
        let result = plan(for: item)
        #expect(result?.itemID == item.id)
        #expect(result?.identifier == "care-\(item.id.uuidString)")
    }

    @Test func plansComeSoonestFirstAndSkipPastOnes() {
        let plans = ReminderPlanner.plans(
            for: [plant(due: 25), plant(due: 15), plant(due: 21), plant(due: 20)],
            now: now, calendar: calendar
        )
        #expect(plans.map(\.fireDate) == [date(20, hour: 10, minute: 30), date(21, hour: 10, minute: 30), date(25, hour: 10, minute: 30)])
    }

    @Test func staysUnderTheSystemLimitOfPendingReminders() {
        let items = (0..<80).map { plant(due: 20 + $0 % 10) }
        let plans = ReminderPlanner.plans(for: items, now: now, calendar: calendar)
        #expect(plans.count == ReminderPlanner.maxPending)
        #expect(ReminderPlanner.maxPending <= 64)
    }
}
