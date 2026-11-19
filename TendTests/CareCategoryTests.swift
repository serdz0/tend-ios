import Foundation
import Testing
@testable import Tend

/// The calendar's colour groups: one for plants and one for each sort of car task.
@MainActor
struct CareCategoryTests {
    private func car(_ preset: CarTaskPreset, custom: String = "Replace wipers") -> CareItem {
        CareItem(name: "Car", kind: .car, task: preset == .custom ? custom : preset.taskName,
                 recurrence: Recurrence(count: 1, unit: .year), dueDate: TestCalendar.date(2026, 11, 19))
    }

    @Test func plantsAreTheirOwnGroup() {
        let plant = CareItem(name: "Basil", kind: .plant, task: "Water",
                             recurrence: Recurrence(count: 3, unit: .day), dueDate: TestCalendar.date(2026, 11, 19))
        #expect(CareCategory(item: plant) == .plant)
    }

    @Test func carPresetsMapToTheirOwnGroups() {
        #expect(CareCategory(item: car(.stk)) == .inspection)
        #expect(CareCategory(item: car(.insurance)) == .insurance)
        #expect(CareCategory(item: car(.oilService)) == .service)
    }

    @Test func bothTyreSwapsShareOneGroup() {
        #expect(CareCategory(item: car(.winterTyres)) == .tyres)
        #expect(CareCategory(item: car(.summerTyres)) == .tyres)
    }

    @Test func yourOwnCarTasksFallIntoOther() {
        #expect(CareCategory(item: car(.custom)) == .other)
    }

    @Test func everyGroupHasItsOwnIconSoColourIsNeverTheOnlyClue() {
        let symbols = CareCategory.allCases.map(\.symbolName)
        #expect(Set(symbols).count == symbols.count)
    }
}
