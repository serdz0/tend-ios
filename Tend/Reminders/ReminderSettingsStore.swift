import Foundation
import Observation

/// Holds the reminder settings and saves them on the phone each time they change.
@Observable
final class ReminderSettingsStore {
    private static let key = "reminderSettings"
    private let defaults: UserDefaults

    var settings: ReminderSettings {
        didSet { save() }
    }

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
        if let data = defaults.data(forKey: Self.key),
           let saved = try? JSONDecoder().decode(ReminderSettings.self, from: data) {
            settings = saved
        } else {
            settings = ReminderSettings()
        }
        #if DEBUG
        // Launch with `-digestInMinutes 2` to get the morning note in two minutes.
        let minutes = defaults.integer(forKey: "digestInMinutes")
        if minutes > 0 {
            settings.digestTime = TimeOfDay(date: .now.addingTimeInterval(Double(minutes) * 60))
        }
        #endif
    }

    private func save() {
        if let data = try? JSONEncoder().encode(settings) {
            defaults.set(data, forKey: Self.key)
        }
    }
}
