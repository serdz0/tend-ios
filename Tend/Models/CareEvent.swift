import Foundation
import SwiftData

nonisolated enum CareEventKind: String, Codable {
    case done
    case snoozed
}

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
