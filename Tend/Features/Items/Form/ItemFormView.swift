import SwiftData
import SwiftUI

/// The sheet for adding a new plant or car task, or editing an existing one.
struct ItemFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @AppStorage("firstSuccess") private var firstSuccess = false
    @State private var draft: ItemDraft
    private let editing: CareItem?

    init(editing item: CareItem? = nil) {
        editing = item
        _draft = State(initialValue: item.map { ItemDraft(editing: $0) } ?? ItemDraft())
    }

    private var titleText: LocalizedStringKey {
        editing == nil ? "Add something" : "Edit details"
    }

    var body: some View {
        NavigationStack {
            Form {
                ItemWhatSection(draft: $draft, isEditing: editing != nil)
                ItemScheduleSection(draft: $draft)
                ItemReminderSection(draft: $draft)

                if let problem = draft.problems.first {
                    Section {
                        ItemProblemText(problem: problem)
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
                    Button("Save", action: save)
                        .disabled(!draft.isValid)
                }
            }
        }
        .onChange(of: draft.kind) {
            draft.applyKindDefaults()
        }
        .onChange(of: draft.plantType) {
            draft.applyPlantTypeDefaults()
        }
        .onChange(of: draft.carPreset) {
            draft.applyCarPresetDefaults()
        }
    }

    private func cancel() {
        dismiss()
    }

    private func save() {
        if let editing {
            draft.apply(to: editing)
        } else {
            modelContext.insert(draft.makeItem())
            firstSuccess = true
        }
        dismiss()
    }
}

#if DEBUG
#Preview {
    ItemFormView()
        .modelContainer(SampleData.previewContainer())
        .environment(ReminderCenter())
        .environment(ReminderSettingsStore())
}
#endif
