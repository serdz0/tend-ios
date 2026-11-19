import SwiftData
import SwiftUI

/// One item in full: when it is due, how it repeats, its history, and the buttons to act on it.
struct ItemDetailView: View {
    let item: CareItem

    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var isEditing = false
    @State private var isConfirmingDelete = false
    @State private var odometerRequest: OdometerRequest?
    @State private var undo: CareUndo?
    @AppStorage("firstSuccess") private var firstSuccess = false

    var body: some View {
        // After a delete the screen is on its way out; don't read from the removed item.
        if !item.isDeleted {
            List {
                ItemDueSection(item: item, now: .now, onDone: markDone, onSnooze: snooze)
                ItemFactsSection(item: item, onUpdateMileage: updateMileage)
                ItemHistorySection(item: item)

                Section {
                    Button("Remove from my things", systemImage: "trash", role: .destructive, action: askToDelete)
                        .confirmationDialog(
                            "Remove \(item.title)?",
                            isPresented: $isConfirmingDelete,
                            titleVisibility: .visible
                        ) {
                            Button("Remove", role: .destructive, action: delete)
                        } message: {
                            Text("Its history goes with it, and this can't be undone.")
                        }
                }
                .listRowBackground(Theme.card)
            }
            .scrollContentBackground(.hidden)
            .background(Theme.paper)
            .navigationTitle(item.title)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button("Edit", action: edit)
                }
            }
            .sheet(isPresented: $isEditing) {
                ItemFormView(editing: item)
            }
            .sheet(item: $odometerRequest, content: OdometerSheet.init)
            .safeAreaInset(edge: .bottom) {
                if let undo {
                    UndoBar(message: undo.message, onUndo: undoLast, onClose: closeUndo)
                        .transition(.opacity)
                }
            }
        }
    }

    private func markDone() {
        if item.distance != nil {
            odometerRequest = OdometerRequest(item: item, purpose: .done, onMarkedDone: offerUndo)
        } else {
            offerUndo(item.markDone())
        }
    }

    private func snooze() {
        offerUndo(item.snooze())
    }

    private func offerUndo(_ newUndo: CareUndo) {
        firstSuccess = true
        withAnimation { undo = newUndo }
    }

    private func undoLast() {
        withAnimation {
            undo?.apply()
            undo = nil
        }
    }

    private func closeUndo() {
        withAnimation { undo = nil }
    }

    private func updateMileage() {
        odometerRequest = OdometerRequest(item: item, purpose: .update)
    }

    private func edit() {
        isEditing = true
    }

    private func askToDelete() {
        isConfirmingDelete = true
    }

    private func delete() {
        dismiss()
        modelContext.delete(item)
    }
}
