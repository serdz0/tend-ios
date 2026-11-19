import Foundation
import Testing
@testable import Tend

/// Oil service every 15,000 km. 36,500 km a year is exactly 100 km a day, which keeps the sums easy to follow.
@MainActor
struct MileageTests {
    private let calendar = TestCalendar.utc

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 0) -> Date {
        TestCalendar.date(year, month, day, hour: hour)
    }

    private func schedule(lastService: Int = 47_000, reading: Int = 61_000) -> DistanceSchedule {
        DistanceSchedule(intervalKm: 15_000, lastServiceKm: lastService, readingKm: reading,
                         readingDate: date(2026, 11, 19), kmPerYear: 36_500)
    }

    private func oilItem(_ schedule: DistanceSchedule) -> CareItem {
        CareItem(name: "Car", kind: .car, task: "Oil service",
                 schedule: .distance(schedule), dueDate: schedule.dueDate(calendar: calendar))
    }

    // MARK: The estimate

    @Test func dueAtTheLastServiceKmPlusTheInterval() {
        #expect(schedule().dueAtKm == 62_000)
    }

    @Test func thousandKmLeftAtHundredAdayIsTenDays() {
        #expect(schedule().dueDate(calendar: calendar) == date(2026, 11, 29))
    }

    @Test func kmLeftShrinksWithTheDaysSinceTheReading() {
        let s = schedule()
        #expect(s.kmLeft(on: date(2026, 11, 19, hour: 15), calendar: calendar) == 1_000)
        #expect(s.kmLeft(on: date(2026, 11, 24, hour: 8), calendar: calendar) == 500)
    }

    @Test func estimatedKmGrowsWithTheDaysSinceTheReading() {
        #expect(schedule().estimatedKm(on: date(2026, 11, 24), calendar: calendar) == 61_500)
    }

    @Test func pastTheLimitIsOverdueByTheDaysItTookToDriveIt() {
        let s = schedule(lastService: 45_000)   // limit 60,000, reading 61,000
        #expect(s.kmLeft(on: date(2026, 11, 19), calendar: calendar) == -1_000)
        #expect(s.dueDate(calendar: calendar) == date(2026, 11, 9))
    }

    @Test func justPastTheLimitIsAtLeastOneDayOverdue() {
        let s = schedule(lastService: 45_000, reading: 60_050)
        let item = oilItem(s)
        #expect(item.status(now: date(2026, 11, 19, hour: 10), calendar: calendar) == .overdue(days: 1))
    }

    @Test func exactlyAtTheLimitIsDueToday() {
        let s = schedule(lastService: 45_000, reading: 60_000)
        let item = oilItem(s)
        #expect(item.status(now: date(2026, 11, 19, hour: 10), calendar: calendar) == .dueToday)
    }

    // MARK: Checking a reading you type

    @Test func aReadingBelowTheLastServiceIsRejected() {
        let s = schedule()   // last service at 47,000
        #expect(s.accepts(readingKm: 46_999) == false)
        #expect(s.accepts(readingKm: 47_000))
        #expect(s.accepts(readingKm: 62_500))
    }

    // MARK: Marking done and updating the reading

    @Test func markingDoneWithAReadingRestartsTheCountFromThatReading() {
        let oil = oilItem(schedule())
        oil.markDone(now: date(2026, 11, 24, hour: 10), odometerKm: 62_300, calendar: calendar)

        #expect(oil.distance?.lastServiceKm == 62_300)
        #expect(oil.distance?.readingKm == 62_300)
        #expect(oil.dueDate == date(2027, 4, 23))   // 15,000 km at 100 a day = 150 days after 24 Nov
        #expect(oil.events.map(\.kind) == [.done])
    }

    @Test func markingDoneWithoutAReadingAssumesTheEstimatedOdometer() {
        let oil = oilItem(schedule())
        oil.markDone(now: date(2026, 11, 24, hour: 10), calendar: calendar)

        #expect(oil.distance?.lastServiceKm == 61_500)
        #expect(oil.distance?.readingKm == 61_500)
    }

    @Test func updatingTheReadingMovesTheDueDateAndKeepsHistoryClean() {
        let oil = oilItem(schedule())
        oil.updateMileage(km: 61_800, now: date(2026, 11, 24, hour: 10), calendar: calendar)

        #expect(oil.distance?.readingKm == 61_800)
        #expect(oil.dueDate == date(2026, 11, 26))   // 200 km left, two days at 100 a day
        #expect(oil.events.isEmpty)
    }

    @Test func updatingTheReadingOnAnItemWithoutMileageChangesNothing() {
        let monstera = CareItem(name: "Monstera", kind: .plant, task: "Water",
                                recurrence: Recurrence(count: 7, unit: .day), dueDate: date(2026, 11, 20))
        monstera.updateMileage(km: 1_000, now: date(2026, 11, 19), calendar: calendar)
        #expect(monstera.dueDate == date(2026, 11, 20))
        #expect(monstera.distance == nil)
    }
}
