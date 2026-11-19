import Foundation
import Testing
@testable import Tend

/// "My things": plants together, then one group for each car, soonest due first.
@MainActor
struct ItemGroupTests {
    private func plant(_ name: String, due day: Int) -> CareItem {
        CareItem(name: name, kind: .plant, task: "Water",
                 recurrence: Recurrence(count: 7, unit: .day), dueDate: TestCalendar.date(2026, 11, day))
    }

    private func car(_ name: String = "Car", task: String, due day: Int) -> CareItem {
        CareItem(name: name, kind: .car, task: task,
                 recurrence: Recurrence(count: 1, unit: .year), dueDate: TestCalendar.date(2026, 11, day))
    }

    @Test func plantsComeFirstThenEachCar() {
        let groups = ItemGroup.groups(from: [
            car("Skoda", task: "Insurance renewal", due: 5),
            plant("Monstera", due: 3),
            car("Fiat", task: "STK inspection", due: 9),
        ])
        #expect(groups.map(\.title) == ["Plants", "Fiat", "Skoda"])
        #expect(groups.map(\.kind) == [.plant, .car, .car])
    }

    @Test func itemsInAGroupAreSortedBySoonestDue() {
        let groups = ItemGroup.groups(from: [
            plant("Basil", due: 20),
            plant("Monstera", due: 3),
            plant("Aloe", due: 3),
        ])
        #expect(groups[0].items.map(\.name) == ["Aloe", "Monstera", "Basil"])
    }

    @Test func tasksForTheSameCarShareAGroup() {
        let groups = ItemGroup.groups(from: [
            car(task: "STK inspection", due: 4),
            car(task: "Oil service", due: 2),
        ])
        #expect(groups.count == 1)
        #expect(groups[0].items.map(\.task) == ["Oil service", "STK inspection"])
    }

    @Test func groupsWithNothingInThemAreLeftOut() {
        #expect(ItemGroup.groups(from: [plant("Basil", due: 1)]).map(\.title) == ["Plants"])
        #expect(ItemGroup.groups(from: []).isEmpty)
    }
}
