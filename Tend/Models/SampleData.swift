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
        // Launch with `-pileUp YES` to see a pile of overdue plants (for trying Fresh start).
        let pileUp = UserDefaults.standard.bool(forKey: "pileUp")
        func plant(_ type: PlantType, name: String? = nil, dueIn plannedDays: Int) -> CareItem {
            let days = pileUp ? -(abs(plannedDays) + 2) : plannedDays
            return CareItem(
                name: name ?? type.defaultName, kind: .plant, task: "Water",
                schedule: .interval(Recurrence(count: type.wateringDays ?? 7, unit: .day)),
                dueDate: due(in: days), plantType: type
            )
        }

        func history(_ item: CareItem, _ kind: CareEventKind, daysAgo: Int, hour: Int = 9) -> CareItem {
            let day = calendar.date(byAdding: .day, value: -daysAgo, to: today) ?? today
            let time = calendar.date(bySettingHour: hour, minute: 15, second: 0, of: day) ?? day
            item.events.append(CareEvent(date: time, kind: kind))
            return item
        }

        // 61,700 km on the odometer today, last oil change at 47,000, about 12,000 km a year: due in about nine days.
        let oil = DistanceSchedule(intervalKm: 15_000, lastServiceKm: 47_000, readingKm: 61_700,
                                   readingDate: today, kmPerYear: 12_000)

        let items = [
            CareItem(name: "Car", kind: .car, task: CarTaskPreset.stk.taskName,
                     recurrence: Recurrence(count: 2, unit: .year), dueDate: due(in: -3)),
            history(plant(.monstera, dueIn: -1), .done, daysAgo: 8),
            history(plant(.fiddleLeafFig, dueIn: 0), .done, daysAgo: 7, hour: 18),
            history(history(plant(.basil, dueIn: 0), .done, daysAgo: 6), .snoozed, daysAgo: 1, hour: 8),
            history(plant(.peaceLily, dueIn: 4), .done, daysAgo: 3, hour: 20),
            history(plant(.snakePlant, dueIn: 9), .done, daysAgo: 5),
            CareItem(name: "Car", kind: .car, task: CarTaskPreset.oilService.taskName,
                     schedule: .distance(oil), dueDate: oil.dueDate(calendar: calendar)),
            CareItem(name: "Car", kind: .car, task: CarTaskPreset.insurance.taskName,
                     recurrence: Recurrence(count: 1, unit: .year), dueDate: due(in: 11)),
            CareItem(name: "Car", kind: .car, task: CarTaskPreset.winterTyres.taskName,
                     schedule: .yearly(month: 10, day: 31),
                     dueDate: Schedule.nextOccurrence(month: 10, day: 31, after: today, calendar: calendar)),
            CareItem(name: "Car", kind: .car, task: CarTaskPreset.summerTyres.taskName,
                     schedule: .yearly(month: 4, day: 1),
                     dueDate: Schedule.nextOccurrence(month: 4, day: 1, after: today, calendar: calendar)),
        ]

        // Launch with `-itemReminderInMinutes 2` to give every sample item a reminder that many
        // minutes from now (for trying "a note for each thing" without waiting until 10:30).
        let minutes = UserDefaults.standard.integer(forKey: "itemReminderInMinutes")
        if minutes > 0 {
            let soon = calendar.dateComponents([.hour, .minute], from: now.addingTimeInterval(Double(minutes) * 60))
            for item in items {
                item.reminderTime = TimeOfDay(hour: soon.hour ?? 10, minute: soon.minute ?? 30)
            }
        }
        return items
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
