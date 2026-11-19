import Foundation
import Testing
@testable import Tend

/// Routine car care (washing, cleaning, tyre pressure) and the extra car presets. Today is 19 November 2026.
@MainActor
struct CarRoutineTests {
    private let calendar = TestCalendar.utc
    private let now = TestCalendar.date(2026, 11, 19, hour: 8)

    private func date(_ day: Int) -> Date {
        TestCalendar.date(2026, 11, day)
    }

    private func car(_ preset: CarTaskPreset, dueDay: Int) -> CareItem {
        CareItem(name: "Car", kind: .car, task: preset.taskName,
                 recurrence: Recurrence(count: 1, unit: .week), dueDate: date(dueDay))
    }

    // MARK: Presets

    @Test func routineCareRepeatsOftenAndGently() {
        #expect(CarTaskPreset.washExterior.taskName == "Wash the car")
        #expect(CarTaskPreset.washExterior.scheduleStyle == .interval(Recurrence(count: 1, unit: .week)))
        #expect(CarTaskPreset.cleanInterior.taskName == "Clean the interior")
        #expect(CarTaskPreset.cleanInterior.scheduleStyle == .interval(Recurrence(count: 1, unit: .week)))
        #expect(CarTaskPreset.tyrePressure.taskName == "Check tyre pressure")
        #expect(CarTaskPreset.tyrePressure.scheduleStyle == .interval(Recurrence(count: 1, unit: .month)))
    }

    @Test func theExtraPresetsHaveTheAgreedSchedules() {
        #expect(CarTaskPreset.vignette.taskName == "Highway vignette")
        #expect(CarTaskPreset.vignette.scheduleStyle == .interval(Recurrence(count: 1, unit: .year)))
        #expect(CarTaskPreset.firstAidKit.taskName == "Check the first-aid kit")
        #expect(CarTaskPreset.firstAidKit.scheduleStyle == .interval(Recurrence(count: 1, unit: .year)))
        #expect(CarTaskPreset.brakeFluid.taskName == "Brake fluid change")
        #expect(CarTaskPreset.brakeFluid.scheduleStyle == .interval(Recurrence(count: 2, unit: .year)))
        #expect(CarTaskPreset.filtersAndWipers.taskName == "Cabin filter and wipers")
        #expect(CarTaskPreset.filtersAndWipers.scheduleStyle == .interval(Recurrence(count: 1, unit: .year)))
        #expect(CarTaskPreset.batteryCheck.taskName == "Check the car battery")
        #expect(CarTaskPreset.batteryCheck.scheduleStyle == .yearly(month: 10, day: 15))
    }

    @Test func everyPresetBelongsToOneGroupAndNamesAreUnique() {
        let named = CarTaskPreset.allCases.filter { $0 != .custom }
        let grouped = CarTaskGroup.allCases.flatMap(\.presets)
        #expect(Set(grouped) == Set(CarTaskPreset.allCases))
        #expect(grouped.count == CarTaskPreset.allCases.count)
        #expect(Set(named.map(\.taskName)).count == named.count)
    }

    @Test func groupsHoldTheRightThings() {
        #expect(CarTaskGroup.deadlines.presets == [.stk, .insurance, .vignette, .firstAidKit])
        #expect(CarTaskGroup.routine.presets == [.washExterior, .cleanInterior, .tyrePressure])
        #expect(CarTaskGroup.servicing.presets.contains(.oilService))
        #expect(CarTaskGroup.yourOwn.presets == [.custom])
    }

    @Test func tyrePressureMentionsTheCarsOwnApp() {
        #expect(CarTaskPreset.tyrePressure.hint?.contains("MyMazda") == true)
        #expect(CarTaskPreset.stk.hint == nil)
    }

    // MARK: Routine items go easy on you

    @Test func routineCareIsRecognisedByItsTask() {
        #expect(car(.washExterior, dueDay: 19).isRoutine)
        #expect(car(.tyrePressure, dueDay: 19).isRoutine)
        #expect(!car(.stk, dueDay: 19).isRoutine)
        let plant = CareItem(name: "Basil", kind: .plant, task: "Water",
                             recurrence: Recurrence(count: 3, unit: .day), dueDate: date(19))
        #expect(!plant.isRoutine)
    }

    @Test func aMissedChoreIsJustDueTodayNeverOverdue() {
        #expect(car(.washExterior, dueDay: 12).status(now: now, calendar: calendar) == .dueToday)
        #expect(car(.washExterior, dueDay: 22).status(now: now, calendar: calendar) == .upcoming(days: 3))
    }

    @Test func realDeadlinesStillGoOverdue() {
        #expect(car(.stk, dueDay: 16).status(now: now, calendar: calendar) == .overdue(days: 3))
    }

    @Test func aChoreAppearsInTheMorningNoteOnlyOnItsOwnDay() {
        let wash = car(.washExterior, dueDay: 20)
        let plans = ReminderPlanner.plans(for: [wash], settings: ReminderSettings(), now: now, calendar: calendar)
        #expect(plans.map(\.identifier) == ["care-digest-2026-11-20"])

        let missed = car(.washExterior, dueDay: 15)
        #expect(ReminderPlanner.plans(for: [missed], settings: ReminderSettings(), now: now, calendar: calendar).isEmpty)
    }

    @Test func overdueDeadlinesStayInEveryMorningNote() {
        let stk = car(.stk, dueDay: 15)
        let plans = ReminderPlanner.plans(for: [stk], settings: ReminderSettings(), now: now, calendar: calendar)
        #expect(plans.count == 3)
    }

    // MARK: Calendar groups

    @Test func cleaningHasItsOwnGroupAndIcon() {
        #expect(CareCategory(item: car(.washExterior, dueDay: 19)) == .cleaning)
        #expect(CareCategory(item: car(.cleanInterior, dueDay: 19)) == .cleaning)
        #expect(CareCategory.cleaning.title == "Cleaning")
    }

    @Test func otherPresetsFindTheirGroups() {
        #expect(CareCategory(item: car(.tyrePressure, dueDay: 19)) == .tyres)
        #expect(CareCategory(item: car(.brakeFluid, dueDay: 19)) == .service)
        #expect(CareCategory(item: car(.filtersAndWipers, dueDay: 19)) == .service)
        #expect(CareCategory(item: car(.batteryCheck, dueDay: 19)) == .service)
        #expect(CareCategory(item: car(.vignette, dueDay: 19)) == .other)
        #expect(CareCategory(item: car(.firstAidKit, dueDay: 19)) == .other)
    }

    // MARK: The form

    @Test func pickingAChoreFillsInItsInterval() {
        var draft = ItemDraft(now: now, calendar: calendar)
        draft.kind = .car
        draft.carPreset = .washExterior
        draft.applyCarPresetDefaults(now: now, calendar: calendar)
        #expect(draft.interval == Recurrence(count: 1, unit: .week))
        #expect(draft.task == "Wash the car")
    }

    @Test func editingAChoreKeepsItsPreset() {
        let draft = ItemDraft(editing: car(.cleanInterior, dueDay: 19), calendar: calendar)
        #expect(draft.carPreset == .cleanInterior)
    }
}
