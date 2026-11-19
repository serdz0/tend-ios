import Foundation

/// One block on the "My things" screen: all the plants, or all the tasks for one car.
struct ItemGroup: Identifiable {
    let id: String
    let title: String
    let kind: ItemKind
    /// Soonest due first.
    let items: [CareItem]

    /// Plants first, then one group per car in alphabetical order. Empty groups are left out.
    static func groups(from items: [CareItem]) -> [ItemGroup] {
        func soonest(_ items: [CareItem]) -> [CareItem] {
            items.sorted {
                if $0.dueDate != $1.dueDate { return $0.dueDate < $1.dueDate }
                return $0.title.localizedStandardCompare($1.title) == .orderedAscending
            }
        }

        var groups: [ItemGroup] = []

        let plants = items.filter { $0.kind == .plant }
        if !plants.isEmpty {
            groups.append(ItemGroup(id: "plants", title: String(localized: "Plants"), kind: .plant, items: soonest(plants)))
        }

        let cars = Dictionary(grouping: items.filter { $0.kind == .car }, by: \.name)
        for name in cars.keys.sorted(by: { $0.localizedStandardCompare($1) == .orderedAscending }) {
            groups.append(ItemGroup(id: "car:\(name)", title: name, kind: .car, items: soonest(cars[name] ?? [])))
        }
        return groups
    }
}
