import Foundation
import Testing
@testable import Tend

/// The add/edit form: defaults when you pick a type, checks before saving, and turning the form into an item.
@MainActor
struct ItemDraftTests {
    private let calendar = TestCalendar.utc
    private let now = TestCalendar.date(2026, 11, 19, hour: 10)

    private func date(_ year: Int, _ month: Int, _ day: Int) -> Date {
        TestCalendar.date(year, month, day)
    }

    private func newDraft() -> ItemDraft {
        ItemDraft(now: now, calendar: calendar)
    }

    // MARK: Defaults

    @Test func aNewDraftIsAMonsteraDueTodayAtNine() {
        let draft = newDraft()
        #expect(draft.kind == .plant)
        #expect(draft.plantType == .monstera)
        #expect(draft.name == "Monstera")
        #expect(draft.interval == Recurrence(count: 7, unit: .day))
        #expect(draft.firstDueDate == date(2026, 11, 19))
        #expect(draft.reminderTime == TimeOfDay(hour: 9, minute: 0))
        #expect(draft.problems.isEmpty)
    }

    @Test func choosingAPlantTypeSetsItsIntervalAndName() {
        var draft = newDraft()
        draft.plantType = .basil
        draft.applyPlantTypeDefaults()
        #expect(draft.name == "Basil")
        #expect(draft.interval == Recurrence(count: 3, unit: .day))
    }

    @Test func choosingAPlantTypeKeepsANameYouTyped() {
        var draft = newDraft()
        draft.name = "Kitchen palm"
        draft.plantType = .snakePlant
        draft.applyPlantTypeDefaults()
        #expect(draft.name == "Kitchen palm")
        #expect(draft.interval == Recurrence(count: 14, unit: .day))
    }

    @Test func choosingOtherPlantKeepsTheCurrentInterval() {
        var draft = newDraft()
        draft.interval = Recurrence(count: 5, unit: .day)
        draft.plantType = .other
        draft.applyPlantTypeDefaults()
        #expect(draft.interval == Recurrence(count: 5, unit: .day))
    }

    @Test func switchingToCarNamesItCarAndSwitchingBackNamesItAfterThePlantType() {
        var draft = newDraft()
        draft.kind = .car
        draft.applyKindDefaults()
        #expect(draft.name == "Car")

        draft.kind = .plant
        draft.applyKindDefaults()
        #expect(draft.name == "Monstera")
    }

    @Test func choosingWinterTyresPicksTheNextThirtyFirstOfOctober() {
        var draft = newDraft()
        draft.kind = .car
        draft.carPreset = .winterTyres
        draft.applyCarPresetDefaults(now: now, calendar: calendar)
        #expect(draft.firstDueDate == date(2027, 10, 31))
    }

    @Test func choosingSummerTyresPicksTheNextFirstOfApril() {
        var draft = newDraft()
        draft.kind = .car
        draft.carPreset = .summerTyres
        draft.applyCarPresetDefaults(now: now, calendar: calendar)
        #expect(draft.firstDueDate == date(2027, 4, 1))
    }

    @Test func choosingStkSetsTwoYears() {
        var draft = newDraft()
        draft.kind = .car
        draft.carPreset = .stk
        draft.applyCarPresetDefaults(now: now, calendar: calendar)
        #expect(draft.interval == Recurrence(count: 2, unit: .year))
    }

    @Test func choosingOilSetsFifteenThousandKm() {
        var draft = newDraft()
        draft.kind = .car
        draft.carPreset = .oilService
        draft.applyCarPresetDefaults(now: now, calendar: calendar)
        #expect(draft.serviceIntervalKm == 15_000)
    }

    // MARK: Checks before saving

    @Test func aPlantNeedsAName() {
        var draft = newDraft()
        draft.name = "   "
        #expect(draft.problems == [.missingName])
    }

    @Test func aCustomCarTaskNeedsAName() {
        var draft = newDraft()
        draft.kind = .car
        draft.carPreset = .custom
        draft.customTask = ""
        #expect(draft.problems == [.missingTask])
    }

    @Test func aPresetCarTaskNeedsNoCustomName() {
        var draft = newDraft()
        draft.kind = .car
        draft.carPreset = .stk
        draft.customTask = ""
        #expect(draft.problems.isEmpty)
    }

    @Test func theRepeatMustBeAtLeastOne() {
        var draft = newDraft()
        draft.interval = Recurrence(count: 0, unit: .day)
        #expect(draft.problems == [.intervalTooSmall])
    }

    @Test func mileageChecksApplyOnlyToTheOilTask() {
        var draft = newDraft()
        draft.lastServiceKm = 90_000
        draft.currentKm = 10
        #expect(draft.problems.isEmpty)   // a plant ignores mileage

        draft.kind = .car
        draft.carPreset = .oilService
        draft.serviceIntervalKm = 0
        draft.kmPerYear = 0
        #expect(draft.problems == [.serviceIntervalTooSmall, .drivingPerYearTooSmall, .mileageBeforeLastService])
    }

    // MARK: Turning the form into an item

    @Test func makingAPlantGivesAWateringItem() {
        var draft = newDraft()
        draft.name = "Kitchen Monstera"
        draft.firstDueDate = date(2026, 11, 22)
        draft.reminderTime = TimeOfDay(hour: 8, minute: 15)

        let item = draft.makeItem(now: now, calendar: calendar)

        #expect(item.title == "Water Kitchen Monstera")
        #expect(item.kind == .plant)
        #expect(item.plantType == .monstera)
        #expect(item.schedule == .interval(Recurrence(count: 7, unit: .day)))
        #expect(item.dueDate == date(2026, 11, 22))
        #expect(item.reminderTime == TimeOfDay(hour: 8, minute: 15))
    }

    @Test func makingWinterTyresRepeatsOnTheChosenDateEveryYear() {
        var draft = newDraft()
        draft.kind = .car
        draft.carPreset = .winterTyres
        draft.applyKindDefaults()
        draft.applyCarPresetDefaults(now: now, calendar: calendar)
        draft.firstDueDate = date(2027, 10, 25)

        let item = draft.makeItem(now: now, calendar: calendar)

        #expect(item.title == "Fit winter tyres")
        #expect(item.schedule == .yearly(month: 10, day: 25))
        #expect(item.dueDate == date(2027, 10, 25))
    }

    @Test func makingAnOilItemEstimatesTheDueDateFromTheReading() {
        var draft = newDraft()
        draft.kind = .car
        draft.carPreset = .oilService
        draft.applyCarPresetDefaults(now: now, calendar: calendar)
        draft.lastServiceKm = 47_000
        draft.currentKm = 61_000
        draft.kmPerYear = 36_500

        let item = draft.makeItem(now: now, calendar: calendar)

        #expect(item.distance == DistanceSchedule(intervalKm: 15_000, lastServiceKm: 47_000,
                                                  readingKm: 61_000, readingDate: now, kmPerYear: 36_500))
        #expect(item.dueDate == date(2026, 11, 29))
    }

    @Test func makingACustomCarTaskUsesTheTypedNameAndRepeat() {
        var draft = newDraft()
        draft.kind = .car
        draft.carPreset = .custom
        draft.customTask = "Replace wipers"
        draft.interval = Recurrence(count: 1, unit: .year)

        let item = draft.makeItem(now: now, calendar: calendar)

        #expect(item.title == "Replace wipers")
        #expect(item.schedule == .interval(Recurrence(count: 1, unit: .year)))
    }

    // MARK: Editing

    @Test func aDraftFromAnItemRoundTripsItsFields() {
        let item = CareItem(name: "Kitchen Monstera", kind: .plant, task: "Water",
                            schedule: .interval(Recurrence(count: 9, unit: .day)),
                            dueDate: date(2026, 11, 22), plantType: .monstera,
                            reminderTime: TimeOfDay(hour: 8, minute: 15))

        let draft = ItemDraft(editing: item, calendar: calendar)

        #expect(draft.kind == .plant)
        #expect(draft.plantType == .monstera)
        #expect(draft.name == "Kitchen Monstera")
        #expect(draft.interval == Recurrence(count: 9, unit: .day))
        #expect(draft.firstDueDate == date(2026, 11, 22))
        #expect(draft.reminderTime == TimeOfDay(hour: 8, minute: 15))
    }

    @Test func aDraftFromAPresetCarItemFindsThePreset() {
        let item = CareItem(name: "Car", kind: .car, task: "Fit summer tyres",
                            schedule: .yearly(month: 4, day: 1), dueDate: date(2027, 4, 1))
        #expect(ItemDraft(editing: item, calendar: calendar).carPreset == .summerTyres)
    }

    @Test func aDraftFromAnUnknownCarTaskIsCustom() {
        let item = CareItem(name: "Car", kind: .car, task: "Replace wipers",
                            schedule: .interval(Recurrence(count: 1, unit: .year)), dueDate: date(2027, 4, 1))
        let draft = ItemDraft(editing: item, calendar: calendar)
        #expect(draft.carPreset == .custom)
        #expect(draft.customTask == "Replace wipers")
    }

    @Test func applyingChangesKeepsTheDueDateWhenYouDoNotTouchIt() {
        let item = CareItem(name: "Monstera", kind: .plant, task: "Water",
                            schedule: .interval(Recurrence(count: 7, unit: .day)),
                            dueDate: date(2026, 11, 22), plantType: .monstera)
        var draft = ItemDraft(editing: item, calendar: calendar)
        draft.name = "Office Monstera"
        draft.interval = Recurrence(count: 10, unit: .day)

        draft.apply(to: item, now: now, calendar: calendar)

        #expect(item.name == "Office Monstera")
        #expect(item.schedule == .interval(Recurrence(count: 10, unit: .day)))
        #expect(item.dueDate == date(2026, 11, 22))
    }

    @Test func applyingChangesMovesTheDueDateWhenYouPickANewOne() {
        let item = CareItem(name: "Monstera", kind: .plant, task: "Water",
                            schedule: .interval(Recurrence(count: 7, unit: .day)),
                            dueDate: date(2026, 11, 22), plantType: .monstera)
        var draft = ItemDraft(editing: item, calendar: calendar)
        draft.firstDueDate = date(2026, 11, 30)

        draft.apply(to: item, now: now, calendar: calendar)

        #expect(item.dueDate == date(2026, 11, 30))
    }

    @Test func editingAYearlyDateChangesTheDayItRepeatsOn() {
        let item = CareItem(name: "Car", kind: .car, task: "Fit winter tyres",
                            schedule: .yearly(month: 10, day: 31), dueDate: date(2027, 10, 31))
        var draft = ItemDraft(editing: item, calendar: calendar)
        draft.firstDueDate = date(2027, 10, 20)

        draft.apply(to: item, now: now, calendar: calendar)

        #expect(item.schedule == .yearly(month: 10, day: 20))
        #expect(item.dueDate == date(2027, 10, 20))
    }

    @Test func editingMileageRestartsTheReadingDateOnlyWhenTheReadingChanged() {
        let schedule = DistanceSchedule(intervalKm: 15_000, lastServiceKm: 47_000, readingKm: 61_000,
                                        readingDate: date(2026, 11, 10), kmPerYear: 36_500)
        let item = CareItem(name: "Car", kind: .car, task: "Oil service", schedule: .distance(schedule),
                            dueDate: schedule.dueDate(calendar: calendar))

        var untouched = ItemDraft(editing: item, calendar: calendar)
        untouched.kmPerYear = 18_250   // 50 km a day
        untouched.apply(to: item, now: now, calendar: calendar)
        #expect(item.distance?.readingDate == date(2026, 11, 10))
        #expect(item.distance?.kmPerYear == 18_250)

        var changed = ItemDraft(editing: item, calendar: calendar)
        changed.currentKm = 61_500
        changed.apply(to: item, now: now, calendar: calendar)
        #expect(item.distance?.readingDate == now)
        #expect(item.distance?.readingKm == 61_500)
    }
}
