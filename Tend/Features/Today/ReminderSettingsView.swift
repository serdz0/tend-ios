import SwiftUI

/// Every way to change how Tend reminds you, in one place.
struct ReminderSettingsView: View {
    @Environment(ReminderSettingsStore.self) private var store
    @Environment(ReminderCenter.self) private var reminders
    @Environment(\.dismiss) private var dismiss
    @Environment(\.openURL) private var openURL
    @AppStorage("playfulExtras") private var playfulExtras = true

    var body: some View {
        @Bindable var store = store

        NavigationStack {
            Form {
                Section {
                    Picker("How Tend reminds you", selection: $store.settings.style) {
                        Text("One note each morning").tag(ReminderStyle.digest)
                        Text("A note for each thing").tag(ReminderStyle.perItem)
                    }
                    .pickerStyle(.inline)
                    .labelsHidden()
                } header: {
                    Text("How should Tend remind you?")
                } footer: {
                    if store.settings.style == .digest {
                        Text("One calm note a day with everything that is waiting. Fewer pings, same help.")
                    } else {
                        Text("A reminder on each thing's own day, at the time you chose when you added it.")
                    }
                }

                if store.settings.style == .digest {
                    Section {
                        DatePicker("Arrives at", selection: digestTime, displayedComponents: .hourAndMinute)
                    } footer: {
                        Text("If you don't open Tend for 3 days, the notes pause by themselves. Opening it brings them back.")
                    }
                }

                Section("Quiet days") {
                    if let until = store.settings.activePause(now: .now) {
                        Label("Quiet until \(until, format: .dateTime.weekday(.wide).day().month(.wide))",
                              systemImage: "moon.zzz")
                        Button("Start reminding me again", action: resume)
                    } else {
                        Menu("Take a quiet break", systemImage: "moon.zzz") {
                            Button("Rest of today") { pause(days: 1) }
                            Button("3 days") { pause(days: 3) }
                            Button("A week") { pause(days: 7) }
                        }
                    }
                }

                Section {
                    Toggle("Check in if I keep snoozing something", isOn: $store.settings.snoozeCheckIn)
                } footer: {
                    Text("After three snoozes in a row, Today asks gently if the schedule fits. No notification.")
                }

                Section {
                    Toggle("Leaf burst and a little buzz when I finish something", isOn: $playfulExtras)
                } header: {
                    Text("Little extras")
                } footer: {
                    Text("Switch off for a plain tick. Reduce Motion in iOS Settings also turns off the leaves.")
                }

                Section("Permission") {
                    permissionRow
                }
            }
            .listRowBackground(Theme.card)
            .scrollContentBackground(.hidden)
            .background(Theme.paper)
            .navigationTitle("How Tend talks to you")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done", action: close)
                }
            }
        }
    }

    @ViewBuilder
    private var permissionRow: some View {
        switch reminders.status {
        case .notDetermined:
            Button("Turn on reminders", systemImage: "bell", action: askPermission)
        case .denied:
            Button("Reminders are off. Open Settings to turn them on.", systemImage: "bell.slash", action: openSettings)
        case .allowed:
            Label("Reminders are on", systemImage: "bell.badge")
        case .unknown:
            EmptyView()
        }
    }

    private var digestTime: Binding<Date> {
        Binding(
            get: { store.settings.digestTime.date(on: .now) },
            set: { store.settings.digestTime = TimeOfDay(date: $0) }
        )
    }

    private func pause(days: Int) {
        store.settings.pause(forDays: days, from: .now)
    }

    private func resume() {
        store.settings.resume()
    }

    private func askPermission() {
        Task { await reminders.requestPermission() }
    }

    private func openSettings() {
        if let url = URL(string: UIApplication.openSettingsURLString) {
            openURL(url)
        }
    }

    private func close() {
        dismiss()
    }
}

#if DEBUG
#Preview {
    ReminderSettingsView()
        .environment(ReminderCenter())
        .environment(ReminderSettingsStore())
}
#endif
