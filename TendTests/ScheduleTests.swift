import Foundation
import Testing
@testable import Tend

/// Fixed-date-every-year schedules (tyres) and time-of-day for reminders.
@MainActor
struct ScheduleTests {
    private let calendar = TestCalendar.utc

    private func date(_ year: Int, _ month: Int, _ day: Int, hour: Int = 0) -> Date {
        TestCalendar.date(year, month, day, hour: hour)
    }

    private func winterTyres(due: Date) -> CareItem {
        CareItem(name: "Car", kind: .car, task: "Fit winter tyres",
                 schedule: .yearly(month: 10, day: 31), dueDate: due)
    }

    // MARK: Next occurrence of a calendar date

    @Test func nextOccurrenceLaterThisYear() {
        let next = Schedule.nextOccurrence(month: 12, day: 24, after: date(2026, 11, 19, hour: 10), calendar: calendar)
        #expect(next == date(2026, 12, 24))
    }

    @Test func nextOccurrenceWrapsToNextYear() {
        let next = Schedule.nextOccurrence(month: 10, day: 31, after: date(2026, 11, 19), calendar: calendar)
        #expect(next == date(2027, 10, 31))
    }

    @Test func nextOccurrenceIsStrictlyAfterTheGivenDay() {
        let sameDay = Schedule.nextOccurrence(month: 10, day: 31, after: date(2026, 10, 31), calendar: calendar)
        let sameDayLater = Schedule.nextOccurrence(month: 10, day: 31, after: date(2026, 10, 31, hour: 14), calendar: calendar)
        #expect(sameDay == date(2027, 10, 31))
        #expect(sameDayLater == date(2027, 10, 31))
    }

    // MARK: Marking a yearly item done

    @Test func yearlyDoneEarlyGoesToNextYear() {
        let tyres = winterTyres(due: date(2026, 10, 31))
        tyres.markDone(now: date(2026, 10, 20, hour: 10), calendar: calendar)
        #expect(tyres.dueDate == date(2027, 10, 31))
    }

    @Test func yearlyDoneLateGoesToNextYear() {
        let tyres = winterTyres(due: date(2026, 10, 31))
        tyres.markDone(now: date(2026, 11, 5, hour: 10), calendar: calendar)
        #expect(tyres.dueDate == date(2027, 10, 31))
    }

    @Test func yearlyDoneAfterSnoozeStillGoesToNextYear() {
        let tyres = winterTyres(due: date(2026, 10, 31))
        tyres.snooze(now: date(2026, 10, 31, hour: 9), calendar: calendar)
        tyres.markDone(now: date(2026, 11, 1, hour: 9), calendar: calendar)
        #expect(tyres.dueDate == date(2027, 10, 31))
    }

    @Test func yearlyDoneRecordsHistory() {
        let tyres = winterTyres(due: date(2026, 10, 31))
        tyres.markDone(now: date(2026, 10, 20, hour: 10), calendar: calendar)
        #expect(tyres.events.map(\.kind) == [.done])
    }

    // MARK: Time of day

    @Test func timeOfDayDefaultsToNineInTheMorning() {
        #expect(TimeOfDay.defaultReminder == TimeOfDay(hour: 9, minute: 0))
    }

    @Test func timeOfDayBecomesADateOnTheGivenDay() {
        let time = TimeOfDay(hour: 7, minute: 30)
        #expect(time.date(on: date(2026, 11, 19, hour: 15), calendar: calendar)
                == TestCalendar.date(2026, 11, 19, hour: 7, minute: 30))
    }

    @Test func timeOfDayReadsBackFromADate() {
        let time = TimeOfDay(date: TestCalendar.date(2026, 11, 19, hour: 18, minute: 45), calendar: calendar)
        #expect(time == TimeOfDay(hour: 18, minute: 45))
    }
}
