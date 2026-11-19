import SwiftUI

/// Says in words what has to be fixed before the item can be saved.
struct ItemProblemText: View {
    let problem: ItemDraft.Problem

    var body: some View {
        Label(message, systemImage: "exclamationmark.circle")
            .font(.subheadline)
            .foregroundStyle(.secondary)
    }

    private var message: LocalizedStringKey {
        switch problem {
        case .missingName: "It needs a name, so you can spot it later."
        case .missingTask: "What needs doing? Add a short task name."
        case .intervalTooSmall: "Pick a number of 1 or more."
        case .serviceIntervalTooSmall: "Pick a distance of at least 1 km."
        case .drivingPerYearTooSmall: "Roughly how many km do you drive in a year?"
        case .mileageBeforeLastService: "The odometer can't be lower than it was at the last service."
        }
    }
}
