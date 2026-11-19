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
                DatePicker("Next time", selection: $draft.firstDueDate, displayedComponents: .date)
            } header: {
                Text("How often?")
            } footer: {
                IntervalHint(draft: draft)
            }
        case .yearly:
            Section {
                DatePicker("On", selection: $draft.firstDueDate, displayedComponents: .date)
            } header: {
                Text("Every year")
            } footer: {
                Text("It comes round on this date every year, whether you do it early or a little late.")
            }
        case .distance:
            ItemMileageSection(draft: $draft)
        }
    }
}
