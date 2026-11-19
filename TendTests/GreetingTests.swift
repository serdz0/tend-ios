import Foundation
import Testing
@testable import Tend

struct GreetingTests {
    private let calendar = TestCalendar.utc

    private func greeting(atHour hour: Int) -> String {
        Greeting.text(at: TestCalendar.date(2026, 11, 19, hour: hour), calendar: calendar)
    }

    @Test func morningRunsFromFiveToNoon() {
        #expect(greeting(atHour: 5) == "Good morning")
        #expect(greeting(atHour: 11) == "Good morning")
    }

    @Test func afternoonRunsFromNoonToSix() {
        #expect(greeting(atHour: 12) == "Good afternoon")
        #expect(greeting(atHour: 17) == "Good afternoon")
    }

    @Test func eveningRunsFromSixToTen() {
        #expect(greeting(atHour: 18) == "Good evening")
        #expect(greeting(atHour: 21) == "Good evening")
    }

    @Test func lateNightsGetAGentleHello() {
        #expect(greeting(atHour: 22) == "Hello, night owl")
        #expect(greeting(atHour: 3) == "Hello, night owl")
    }
}
