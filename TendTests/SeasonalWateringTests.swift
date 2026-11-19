import Foundation
import Testing
@testable import Tend

/// Plants whose watering follows the seasons (northern hemisphere).
@MainActor
struct SeasonalWateringTests {
    private let calendar = TestCalendar.utc

    private func date(_ month: Int, _ day: Int, year: Int = 2026) -> Date {
        TestCalendar.date(year, month, day, hour: 9)
    }

    private func dipladenia(followsSeasons: Bool = true, due: Date) -> CareItem {
        let item = CareItem(name: "Dipladenia", kind: .plant, task: "Water",
                            schedule: .interval(Recurrence(count: 7, unit: .day)),
                            dueDate: due, plantType: .dipladenia)
        item.followsSeasons = followsSeasons
        return item
    }

    // MARK: Seasons

    @Test func seasonsFollowTheMonths() {
        #expect(Season.of(date(3, 15), calendar: calendar) == .shoulder)
        #expect(Season.of(date(4, 1), calendar: calendar) == .growing)
        #expect(Season.of(date(9, 30), calendar: calendar) == .growing)
        #expect(Season.of(date(10, 1), calendar: calendar) == .shoulder)
        #expect(Season.of(date(11, 1), calendar: calendar) == .rest)
        #expect(Season.of(date(12, 25), calendar: calendar) == .rest)
        #expect(Season.of(date(1, 10, year: 2027), calendar: calendar) == .rest)
        #expect(Season.of(date(2, 28, year: 2027), calendar: calendar) == .rest)
    }

    @Test func seasonsHaveWords() {
        #expect(Season.growing.name == "summer")
        #expect(Season.shoulder.name == "spring or autumn")
        #expect(Season.rest.name == "winter")
    }

    // MARK: Which plants

    @Test func onlyPlantsWithGoodEvidenceFollowSeasons() {
        #expect(PlantType.dipladenia.seasonalWatering == SeasonalWatering(growing: 4, shoulder: 7, rest: 14))
        #expect(PlantType.dracaena.seasonalWatering == SeasonalWatering(growing: 7, shoulder: 10, rest: 14))
        #expect(PlantType.strelitzia.seasonalWatering == SeasonalWatering(growing: 7, shoulder: 10, rest: 14))
        #expect(PlantType.zzPlant.seasonalWatering == SeasonalWatering(growing: 14, shoulder: 18, rest: 25))
        #expect(PlantType.basil.seasonalWatering == nil)
        #expect(PlantType.camellia.seasonalWatering == nil)
        #expect(PlantType.campanula.seasonalWatering == nil)
        #expect(PlantType.monstera.seasonalWatering == nil)
    }

    @Test func daysDependOnTheDate() {
        let watering = SeasonalWatering(growing: 4, shoulder: 7, rest: 14)
        #expect(watering.days(on: date(7, 1), calendar: calendar) == 4)
        #expect(watering.days(on: date(10, 20), calendar: calendar) == 7)
        #expect(watering.days(on: date(12, 20), calendar: calendar) == 14)
    }

    @Test func theSummaryIsPlainWords() {
        let watering = SeasonalWatering(growing: 4, shoulder: 7, rest: 14)
        #expect(watering.summary == "Days between waterings: summer 4, spring or autumn 7, winter 14.")
    }

    // MARK: Marking done

    @Test func summerWateringIsFrequent() {
        let plant = dipladenia(due: date(7, 10))
        plant.markDone(now: date(7, 10), calendar: calendar)
        #expect(calendar.startOfDay(for: plant.dueDate) == TestCalendar.date(2026, 7, 14))
        #expect(plant.schedule == .interval(Recurrence(count: 4, unit: .day)))
    }

    @Test func winterWateringIsRare() {
        let plant = dipladenia(due: date(12, 10))
        plant.markDone(now: date(12, 10), calendar: calendar)
        #expect(calendar.startOfDay(for: plant.dueDate) == TestCalendar.date(2026, 12, 24))
        #expect(plant.schedule == .interval(Recurrence(count: 14, unit: .day)))
    }

    @Test func aPlantNotFollowingSeasonsKeepsItsOwnInterval() {
        let plant = dipladenia(followsSeasons: false, due: date(12, 10))
        plant.markDone(now: date(12, 10), calendar: calendar)
        #expect(calendar.startOfDay(for: plant.dueDate) == TestCalendar.date(2026, 12, 17))
    }

    @Test func undoPutsTheOldIntervalBack() {
        let plant = dipladenia(due: date(12, 10))
        let undo = plant.markDone(now: date(12, 10), calendar: calendar)
        undo.apply()
        #expect(plant.schedule == .interval(Recurrence(count: 7, unit: .day)))
    }

    // MARK: Calendar

    @Test func futureDatesFollowTheChangingSeason() {
        // Due 20 Oct (shoulder, 7 days), then 27 Oct (shoulder, 7), 3 Nov (winter, 14), 17 Nov.
        let plant = dipladenia(due: date(10, 20))
        let entries = CalendarEntries(items: [plant], from: date(10, 1), through: date(11, 30),
                                      now: date(10, 19), calendar: calendar)
        var expected: [Date] = []
        var day = TestCalendar.date(2026, 10, 1)
        while day <= TestCalendar.date(2026, 11, 30) {
            if entries.entries(on: day).contains(where: { $0.kind == .expected }) { expected.append(day) }
            day = calendar.date(byAdding: .day, value: 1, to: day)!
        }
        #expect(expected == [TestCalendar.date(2026, 10, 27), TestCalendar.date(2026, 11, 3), TestCalendar.date(2026, 11, 17)])
    }

    // MARK: The form

    @Test func pickingASeasonalPlantTurnsSeasonsOnWithTheCurrentInterval() {
        var draft = ItemDraft(now: date(12, 1), calendar: calendar)
        draft.plantType = .dipladenia
        draft.applyPlantTypeDefaults(now: date(12, 1), calendar: calendar)
        #expect(draft.followsSeasons)
        #expect(draft.interval == Recurrence(count: 14, unit: .day))
    }

    @Test func pickingAnotherPlantTurnsThemOff() {
        var draft = ItemDraft(now: date(12, 1), calendar: calendar)
        draft.plantType = .dipladenia
        draft.applyPlantTypeDefaults(now: date(12, 1), calendar: calendar)
        draft.plantType = .monstera
        draft.applyPlantTypeDefaults(now: date(12, 1), calendar: calendar)
        #expect(!draft.followsSeasons)
        #expect(draft.interval == Recurrence(count: 7, unit: .day))
    }

    @Test func theSavedPlantRemembersToFollowSeasons() {
        var draft = ItemDraft(now: date(7, 1), calendar: calendar)
        draft.plantType = .dipladenia
        draft.applyPlantTypeDefaults(now: date(7, 1), calendar: calendar)
        draft.name = "Hall dipladenia"
        let item = draft.makeItem(now: date(7, 1), calendar: calendar)
        #expect(item.followsSeasons)
        #expect(item.schedule == .interval(Recurrence(count: 4, unit: .day)))
    }

    @Test func switchingSeasonsOffKeepsYourOwnInterval() {
        var draft = ItemDraft(now: date(7, 1), calendar: calendar)
        draft.plantType = .dipladenia
        draft.applyPlantTypeDefaults(now: date(7, 1), calendar: calendar)
        draft.followsSeasons = false
        draft.interval = Recurrence(count: 6, unit: .day)
        let item = draft.makeItem(now: date(7, 1), calendar: calendar)
        #expect(!item.followsSeasons)
        #expect(item.schedule == .interval(Recurrence(count: 6, unit: .day)))
    }

    @Test func editingKeepsTheSetting() {
        let draft = ItemDraft(editing: dipladenia(due: date(7, 10)), calendar: calendar)
        #expect(draft.followsSeasons)
        #expect(!ItemDraft(editing: dipladenia(followsSeasons: false, due: date(7, 10)), calendar: calendar).followsSeasons)
    }

    @Test func existingPlantsStayFixedByDefault() {
        let plant = CareItem(name: "Fern", kind: .plant, task: "Water",
                             recurrence: Recurrence(count: 7, unit: .day), dueDate: date(7, 10))
        #expect(!plant.followsSeasons)
    }
}
