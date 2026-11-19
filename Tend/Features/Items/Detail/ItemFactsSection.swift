import SwiftUI

/// How the item repeats, the reminder time and, for oil, the mileage details.
struct ItemFactsSection: View {
    let item: CareItem
    let onUpdateMileage: () -> Void

    var body: some View {
        Section("Good to know") {
            LabeledContent("Repeats") {
                ScheduleText(schedule: item.schedule)
            }
            if let type = item.plantType {
                LabeledContent("Type", value: type.displayName)
            }
            if item.kind == .car, let hint = CarTaskPreset.preset(named: item.task)?.hint {
                Label(hint, systemImage: "lightbulb")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
            }
            LabeledContent("Reminder") {
                Text(item.reminderTime.date(on: .now), format: .dateTime.hour().minute())
            }

            if let distance = item.distance {
                LabeledContent("Odometer (estimate)") {
                    Text("\(distance.estimatedKm(on: .now), format: .number) km")
                }
                LabeledContent("Last service at") {
                    Text("\(distance.lastServiceKm, format: .number) km")
                }
                LabeledContent("Driven per year") {
                    Text("About \(distance.kmPerYear, format: .number) km")
                }
                Button("Update mileage", systemImage: "speedometer", action: onUpdateMileage)
            }
        }
        .listRowBackground(Theme.card)
    }
}
