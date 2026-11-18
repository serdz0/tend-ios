import SwiftData
import SwiftUI

@main
struct TendApp: App {
    private let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: CareItem.self, CareEvent.self)
        } catch {
            fatalError("Couldn't open the database: \(error)")
        }
        #if DEBUG
        SampleData.seedIfEmpty(in: container.mainContext)
        #endif
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
