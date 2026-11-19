import SwiftUI

/// The middle of the form. What it asks depends on how the task repeats:
/// every so often, on a date each year, or every so many kilometres.
struct ItemScheduleSection: View {
    @Binding var draft: ItemDraft

    var body: some View {
        switch draft.style {
        case .interval:
            Section {
                Stepper(value: $draft.interval.count, in: 1...365) {
                    RecurrenceText(recurrence: draft.interval)
                }
                Picker("Unit", selection: $draft.interval.unit) {
                    ForEach(RecurrenceUnit.allCases) { unit in
                        Text(unit.pluralName).tag(unit)
                    }
                }
                DatePicker("Next due", selection: $draft.firstDueDate, displayedComponents: .date)
            } header: {
                Text("Repeats")
            } footer: {
                IntervalHint(draft: draft)
            }
        case .yearly:
            Section {
                DatePicker("Due", selection: $draft.firstDueDate, displayedComponents: .date)
            } header: {
                Text("Repeats every year")
            } footer: {
                Text("It comes round on this date every year, whenever you do it.")
            }
        case .distance:
            ItemMileageSection(draft: $draft)
        }
    }
}
