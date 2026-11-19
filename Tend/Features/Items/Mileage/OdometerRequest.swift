import Foundation

/// A request to show the odometer sheet for one item. Setting it opens the sheet; clearing it closes it.
struct OdometerRequest: Identifiable {
    let item: CareItem
    let purpose: OdometerPurpose
    /// Called after the item is marked done, with the way to take it back.
    var onMarkedDone: (CareUndo) -> Void = { _ in }

    var id: UUID { item.id }
}
