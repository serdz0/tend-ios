import SwiftData
import SwiftUI

/// The sheet for adding a new plant or car task, or editing an existing one.
struct ItemFormView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var draft: ItemDraft
    private let editing: CareItem?

    init(editing item: CareItem? = nil) {
        editing = item
        _draft = State(initialValue: item.map { ItemDraft(editing: $0) } ?? ItemDraft())
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
            .navigationTitle(editing == nil ? "Add something" : "Edit details")
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
        }
        dismiss()
    }
}

#if DEBUG
#Preview {
    ItemFormView()
        .modelContainer(SampleData.previewContainer())
}
#endif
