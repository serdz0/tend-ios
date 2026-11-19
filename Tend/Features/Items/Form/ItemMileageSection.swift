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
            Text("Kilometres")
        } footer: {
            Text("Your phone can't read the odometer, so Tend estimates the due date from how far you drive in a year. Give it a fresh reading now and then and the estimate gets sharper.")
        }
    }
}
