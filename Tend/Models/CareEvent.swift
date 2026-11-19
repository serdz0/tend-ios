import Foundation
import SwiftData

/// One line in an item's history: it was done, or it was snoozed.
@Model
final class CareEvent {
    var date: Date
    var kind: CareEventKind
    var item: CareItem?

    init(date: Date, kind: CareEventKind) {
        self.date = date
        self.kind = kind
    }
}
