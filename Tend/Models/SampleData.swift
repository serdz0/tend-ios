#if DEBUG
import Foundation
import SwiftData

/// Made-up plants and car tasks for previews and the first run in debug builds.
enum SampleData {
    static func items(now: Date = .now, calendar: Calendar = .current) -> [CareItem] {
        let today = calendar.startOfDay(for: now)
        func due(in days: Int) -> Date {
            calendar.date(byAdding: .day, value: days, to: today) ?? today
        }

        return [
            CareItem(name: "Car", kind: .car, task: "STK inspection",
                     recurrence: Recurrence(count: 2, unit: .year), dueDate: due(in: -3)),
            CareItem(name: "Monstera", kind: .plant, task: "Water",
                     recurrence: Recurrence(count: 7, unit: .day), dueDate: due(in: -1)),
            CareItem(name: "Fiddle leaf fig", kind: .plant, task: "Water",
                     recurrence: Recurrence(count: 7, unit: .day), dueDate: due(in: 0)),
            CareItem(name: "Basil", kind: .plant, task: "Water",
                     recurrence: Recurrence(count: 3, unit: .day), dueDate: due(in: 0)),
            CareItem(name: "Peace lily", kind: .plant, task: "Water",
                     recurrence: Recurrence(count: 10, unit: .day), dueDate: due(in: 4)),
            CareItem(name: "Car", kind: .car, task: "Winter tyre swap",
                     recurrence: Recurrence(count: 6, unit: .month), dueDate: due(in: 12)),
            CareItem(name: "Car", kind: .car, task: "Insurance renewal",
                     recurrence: Recurrence(count: 1, unit: .year), dueDate: due(in: 34)),
        ]
    }

    /// Adds the sample items the first time a debug build runs.
    static func seedIfEmpty(in context: ModelContext) {
        let existing = (try? context.fetchCount(FetchDescriptor<CareItem>())) ?? 0
        guard existing == 0 else { return }
        for item in items() {
            context.insert(item)
        }
    }

    /// An in-memory database filled with the sample items, for `#Preview`.
    static func previewContainer() -> ModelContainer {
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        guard let container = try? ModelContainer(for: CareItem.self, CareEvent.self, configurations: configuration) else {
            fatalError("Couldn't create the preview database.")
        }
        for item in items() {
            container.mainContext.insert(item)
        }
        return container
    }
}
#endif
