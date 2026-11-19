import Foundation

/// What the add/edit form is working on, before it becomes a saved item.
///
/// Holds the form's choices, fills in sensible defaults when a type is picked, says what is
/// wrong before saving, and turns itself into an item (or applies itself to an existing one).
struct ItemDraft {
    enum Problem: Equatable {
        case missingName
        case missingTask
        case intervalTooSmall
        case serviceIntervalTooSmall
        case drivingPerYearTooSmall
        case mileageBeforeLastService
    }

    /// Which date and number fields the form should show.
    enum Style {
        case interval
        case yearly
        case distance
    }

    var kind: ItemKind = .plant
    var plantType: PlantType = .monstera
    var carPreset: CarTaskPreset = .stk
    var name: String
    var customTask = ""
    var interval: Recurrence
    /// The next due date. For a fixed-date task its month and day become the day it repeats on.
    var firstDueDate: Date
    var reminderTime = TimeOfDay.defaultReminder
    var serviceIntervalKm = 15_000
    var lastServiceKm = 0
    var currentKm = 0
    var kmPerYear = 15_000

    /// When editing: the reading the item already had, so an unchanged reading keeps its date.
    private var originalReadingKm: Int?
    private var originalReadingDate: Date?

    /// A new plant, due today.
    init(now: Date = .now, calendar: Calendar = .current) {
        name = PlantType.monstera.defaultName
        interval = Recurrence(count: PlantType.monstera.wateringDays ?? 7, unit: .day)
        firstDueDate = calendar.startOfDay(for: now)
    }

    /// A draft that edits an existing item.
    init(editing item: CareItem, calendar: Calendar = .current) {
        kind = item.kind
        name = item.name
        plantType = item.plantType ?? .other
        reminderTime = item.reminderTime
        firstDueDate = calendar.startOfDay(for: item.dueDate)
        interval = Recurrence(count: 1, unit: .year)

        if item.kind == .car {
            let preset = CarTaskPreset.preset(named: item.task)
            carPreset = preset ?? .custom
            customTask = preset == nil ? item.task : ""
        }

        switch item.schedule {
        case .interval(let recurrence):
            interval = recurrence
        case .yearly:
            break
        case .distance(let distance):
            serviceIntervalKm = distance.intervalKm
            lastServiceKm = distance.lastServiceKm
            currentKm = distance.readingKm
            kmPerYear = distance.kmPerYear
            originalReadingKm = distance.readingKm
            originalReadingDate = distance.readingDate
        }
    }

    // MARK: What the form shows

    /// The reminder time as a date, for a time picker. Only the hour and minute matter.
    var reminderDate: Date {
        get { reminderTime.date(on: .now) }
        set { reminderTime = TimeOfDay(date: newValue) }
    }

    var style: Style {
        guard kind == .car else { return .interval }
        switch carPreset.scheduleStyle {
        case .interval: return .interval
        case .yearly: return .yearly
        case .distance: return .distance
        }
    }

    /// The task as it appears on Today: "Water" for plants, the preset or typed name for cars.
    var task: String {
        switch kind {
        case .plant: "Water"
        case .car: carPreset == .custom ? customTask.trimmingCharacters(in: .whitespacesAndNewlines) : carPreset.taskName
        }
    }

    // MARK: Defaults when a choice changes

    /// Call after `kind` changes.
    mutating func applyKindDefaults(now: Date = .now, calendar: Calendar = .current) {
        if isDefaultName(name) {
            name = kind == .plant ? plantType.defaultName : "Car"
        }
        switch kind {
        case .plant: applyPlantTypeDefaults()
        case .car: applyCarPresetDefaults(now: now, calendar: calendar)
        }
    }

    /// Call after `plantType` changes. Keeps a name you typed yourself.
    mutating func applyPlantTypeDefaults() {
        if isDefaultName(name) {
            name = plantType.defaultName
        }
        if let days = plantType.wateringDays {
            interval = Recurrence(count: days, unit: .day)
        }
    }

    /// Call after `carPreset` changes.
    mutating func applyCarPresetDefaults(now: Date = .now, calendar: Calendar = .current) {
        switch carPreset.scheduleStyle {
        case .interval(let recurrence):
            interval = recurrence
        case .yearly(let month, let day):
            let today = calendar.startOfDay(for: now)
            let yesterday = calendar.date(byAdding: .day, value: -1, to: today) ?? today
            firstDueDate = Schedule.nextOccurrence(month: month, day: day, after: yesterday, calendar: calendar)
        case .distance(let km):
            serviceIntervalKm = km
        }
    }

    /// True for an empty name, "Car", or the stock name of any plant type: safe to replace.
    private func isDefaultName(_ name: String) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty || trimmed == "Car" || PlantType.allCases.contains { $0.defaultName == trimmed }
    }

    // MARK: Checks before saving

    var problems: [Problem] {
        var problems: [Problem] = []
        if name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            problems.append(.missingName)
        }
        if kind == .car, carPreset == .custom, task.isEmpty {
            problems.append(.missingTask)
        }
        switch style {
        case .interval:
            if interval.count < 1 { problems.append(.intervalTooSmall) }
        case .yearly:
            break
        case .distance:
            if serviceIntervalKm < 1 { problems.append(.serviceIntervalTooSmall) }
            if kmPerYear < 1 { problems.append(.drivingPerYearTooSmall) }
            if currentKm < lastServiceKm { problems.append(.mileageBeforeLastService) }
        }
        return problems
    }

    var isValid: Bool {
        problems.isEmpty
    }

    // MARK: Saving

    func makeItem(now: Date = .now, calendar: Calendar = .current) -> CareItem {
        let schedule = schedule(now: now, calendar: calendar)
        return CareItem(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            kind: kind,
            task: task,
            schedule: schedule,
            dueDate: dueDate(for: schedule, calendar: calendar),
            plantType: kind == .plant ? plantType : nil,
            reminderTime: reminderTime
        )
    }

    /// Copies the form's choices onto an existing item. The kind of item cannot change.
    func apply(to item: CareItem, now: Date = .now, calendar: Calendar = .current) {
        let schedule = schedule(now: now, calendar: calendar)
        item.name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        item.task = task
        item.schedule = schedule
        item.dueDate = dueDate(for: schedule, calendar: calendar)
        item.plantType = kind == .plant ? plantType : nil
        item.reminderTime = reminderTime
    }

    private func schedule(now: Date, calendar: Calendar) -> Schedule {
        switch style {
        case .interval:
            return .interval(interval)
        case .yearly:
            let parts = calendar.dateComponents([.month, .day], from: firstDueDate)
            return .yearly(month: parts.month ?? 1, day: parts.day ?? 1)
        case .distance:
            let readingDate = currentKm == originalReadingKm ? (originalReadingDate ?? now) : now
            return .distance(DistanceSchedule(
                intervalKm: serviceIntervalKm,
                lastServiceKm: lastServiceKm,
                readingKm: currentKm,
                readingDate: readingDate,
                kmPerYear: kmPerYear
            ))
        }
    }

    private func dueDate(for schedule: Schedule, calendar: Calendar) -> Date {
        if case .distance(let distance) = schedule {
            return distance.dueDate(calendar: calendar)
        }
        return calendar.startOfDay(for: firstDueDate)
    }
}
