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
        case .missingName: "Give it a name."
        case .missingTask: "Say what the task is."
        case .intervalTooSmall: "Repeat at least every 1."
        case .serviceIntervalTooSmall: "Service every at least 1 km."
        case .drivingPerYearTooSmall: "Enter about how many km you drive per year."
        case .mileageBeforeLastService: "The odometer now can't be lower than at the last service."
        }
    }
}
