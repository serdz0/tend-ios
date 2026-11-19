import SwiftUI

/// Asks for the odometer reading, then either marks the service done or updates the estimate.
struct OdometerSheet: View {
    let request: OdometerRequest

    @Environment(\.dismiss) private var dismiss
    @State private var km: Int

    init(request: OdometerRequest) {
        self.request = request
        _km = State(initialValue: request.item.distance?.estimatedKm(on: .now) ?? 0)
    }

    private var isValid: Bool {
        request.item.distance?.accepts(readingKm: km) ?? false
    }

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    KilometresField(title: "Odometer now", value: $km)
                } header: {
                    Text(request.item.title)
                } footer: {
                    Text(footerText)
                }

                if !isValid, let distance = request.item.distance {
                    Section {
                        Label("The odometer can't be lower than it was at the last service (\(distance.lastServiceKm, format: .number) km).",
                              systemImage: "exclamationmark.circle")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .listRowBackground(Color.clear)
                }
            }
            .listRowBackground(Theme.card)
            .scrollContentBackground(.hidden)
            .background(Theme.paper)
            .navigationTitle(titleText)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel", role: .cancel, action: cancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(saveTitle, action: save)
                        .disabled(!isValid)
                }
            }
        }
        .presentationDetents([.medium])
    }

    private var titleText: LocalizedStringKey {
        switch request.purpose {
        case .done: "Nice work"
        case .update: "Update mileage"
        }
    }

    private var saveTitle: LocalizedStringKey {
        switch request.purpose {
        case .done: "Done"
        case .update: "Save"
        }
    }

    private var footerText: LocalizedStringKey {
        switch request.purpose {
        case .done:
            "What does the odometer say right now? The next service is counted from this number."
        case .update:
            "Tend assumes steady driving between readings, so a fresh number keeps the estimate sharp."
        }
    }

    private func cancel() {
        dismiss()
    }

    private func save() {
        switch request.purpose {
        case .done: request.onMarkedDone(request.item.markDone(odometerKm: km))
        case .update: request.item.updateMileage(km: km)
        }
        dismiss()
    }
}
