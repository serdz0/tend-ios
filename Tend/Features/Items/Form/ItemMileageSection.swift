import SwiftUI

/// The mileage fields for a task that repeats every so many kilometres, such as an oil change.
struct ItemMileageSection: View {
    @Binding var draft: ItemDraft

    var body: some View {
        Section {
            KilometresField(title: "Service every", value: $draft.serviceIntervalKm)
            KilometresField(title: "Last service at", value: $draft.lastServiceKm)
            KilometresField(title: "Odometer now", value: $draft.currentKm)
            KilometresField(title: "Driven per year", value: $draft.kmPerYear)
        } header: {
            Text("Mileage")
        } footer: {
            Text("The phone can't read your odometer. Tend estimates the due date from how far you drive in a year, and re-estimates whenever you enter a new reading.")
        }
    }
}
