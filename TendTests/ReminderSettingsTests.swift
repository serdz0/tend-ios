import Foundation
import Testing
@testable import Tend

/// Today is 19 November 2026.
struct ReminderSettingsTests {
    private let calendar = TestCalendar.utc
    private let now = TestCalendar.date(2026, 11, 19, hour: 14)

    @Test func startsCalm() {
        let settings = ReminderSettings()
        #expect(settings.style == .digest)
        #expect(settings.digestTime == TimeOfDay(hour: 10, minute: 30))
        #expect(settings.pausedUntil == nil)
        #expect(settings.snoozeCheckIn == true)
    }

    @Test func aBreakOfThreeDaysEndsOnTheFourthMorning() {
        var settings = ReminderSettings()
        settings.pause(forDays: 3, from: now, calendar: calendar)

        #expect(settings.pausedUntil == TestCalendar.date(2026, 11, 22))
        #expect(settings.isQuiet(on: TestCalendar.date(2026, 11, 19), calendar: calendar))
        #expect(settings.isQuiet(on: TestCalendar.date(2026, 11, 21, hour: 10), calendar: calendar))
        #expect(!settings.isQuiet(on: TestCalendar.date(2026, 11, 22, hour: 10), calendar: calendar))
    }

    @Test func restOfTodayMeansBackTomorrow() {
        var settings = ReminderSettings()
        settings.pause(forDays: 1, from: now, calendar: calendar)
        #expect(settings.pausedUntil == TestCalendar.date(2026, 11, 20))
    }

    @Test func resumingClearsTheBreak() {
        var settings = ReminderSettings()
        settings.pause(forDays: 7, from: now, calendar: calendar)
        settings.resume()
        #expect(settings.pausedUntil == nil)
        #expect(!settings.isQuiet(on: now, calendar: calendar))
    }

    @Test func aBreakThatHasEndedIsNotShown() {
        var settings = ReminderSettings()
        settings.pause(forDays: 2, from: TestCalendar.date(2026, 11, 10), calendar: calendar)
        #expect(settings.activePause(now: now, calendar: calendar) == nil)

        settings.pause(forDays: 2, from: now, calendar: calendar)
        #expect(settings.activePause(now: now, calendar: calendar) == TestCalendar.date(2026, 11, 21))
    }

    @Test func survivesBeingSavedAndLoaded() throws {
        var settings = ReminderSettings()
        settings.style = .perItem
        settings.digestTime = TimeOfDay(hour: 8, minute: 0)
        settings.snoozeCheckIn = false
        settings.pause(forDays: 3, from: now, calendar: calendar)

        let data = try JSONEncoder().encode(settings)
        #expect(try JSONDecoder().decode(ReminderSettings.self, from: data) == settings)
    }

    @Test func describesItselfInPlainWords() {
        var settings = ReminderSettings()
        // The time follows the phone's own clock style, so build the expectation the same way.
        func time(_ hour: Int, _ minute: Int) -> String {
            TimeOfDay(hour: hour, minute: minute).date(on: .now).formatted(date: .omitted, time: .shortened)
        }
        #expect(settings.summary == "One note each morning at \(time(10, 30))")
        settings.digestTime = TimeOfDay(hour: 8, minute: 5)
        #expect(settings.summary == "One note each morning at \(time(8, 5))")
        settings.style = .perItem
        #expect(settings.summary == "A note for each thing")
    }
}
