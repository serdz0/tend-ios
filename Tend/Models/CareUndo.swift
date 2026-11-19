import Foundation
import SwiftData

/// Everything needed to take back one action (done, snoozed or a fresh start).
///
/// It remembers how each item looked before, so undoing puts the due date and schedule back
/// and removes the history line that the action added.
nonisolated struct CareUndo {
    nonisolated struct Restore {
        let item: CareItem
        let dueDate: Date
        let schedule: Schedule
        /// The history line the action added, if any.
        let event: CareEvent?
    }

    /// A short sentence for the bar that offers the undo, e.g. "Water Basil is done."
    let message: String
    let restores: [Restore]

    func apply() {
        for restore in restores {
            restore.item.dueDate = restore.dueDate
            restore.item.schedule = restore.schedule
            if let event = restore.event {
                restore.item.events.removeAll { $0 === event }
                restore.item.modelContext?.delete(event)
            }
        }
    }
}
