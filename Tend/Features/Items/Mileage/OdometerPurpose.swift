import Foundation

/// Why the odometer sheet is open.
enum OdometerPurpose {
    /// Marking the service done: the count of kilometres starts again from this reading.
    case done
    /// Just telling Tend the current reading, so it can re-estimate the due date.
    case update
}
