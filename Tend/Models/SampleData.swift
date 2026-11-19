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
        func plant(_ type: PlantType, name: String? = nil, dueIn days: Int) -> CareItem {
            CareItem(
                name: name ?? type.defaultName, kind: .plant, task: "Water",
                schedule: .interval(Recurrence(count: type.wateringDays ?? 7, unit: .day)),
                dueDate: due(in: days), plantType: type
            )
        }

        // 61,300 km on the odometer today, last oil change at 47,000, about 12,000 km a year.
        let oil = DistanceSchedule(intervalKm: 15_000, lastServiceKm: 47_000, readingKm: 61_300,
                                   readingDate: today, kmPerYear: 12_000)

        return [
            CareItem(name: "Car", kind: .car, task: CarTaskPreset.stk.taskName,
                     recurrence: Recurrence(count: 2, unit: .year), dueDate: due(in: -3)),
            plant(.monstera, dueIn: -1),
            plant(.fiddleLeafFig, dueIn: 0),
            plant(.basil, dueIn: 0),
            plant(.peaceLily, dueIn: 4),
            plant(.snakePlant, dueIn: 9),
            CareItem(name: "Car", kind: .car, task: CarTaskPreset.oilService.taskName,
                     schedule: .distance(oil), dueDate: oil.dueDate(calendar: calendar)),
            CareItem(name: "Car", kind: .car, task: CarTaskPreset.insurance.taskName,
                     recurrence: Recurrence(count: 1, unit: .year), dueDate: due(in: 34)),
            CareItem(name: "Car", kind: .car, task: CarTaskPreset.winterTyres.taskName,
                     schedule: .yearly(month: 10, day: 31),
                     dueDate: Schedule.nextOccurrence(month: 10, day: 31, after: today, calendar: calendar)),
            CareItem(name: "Car", kind: .car, task: CarTaskPreset.summerTyres.taskName,
                     schedule: .yearly(month: 4, day: 1),
                     dueDate: Schedule.nextOccurrence(month: 4, day: 1, after: today, calendar: calendar)),
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
