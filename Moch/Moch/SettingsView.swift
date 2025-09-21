import SwiftUI
import SwiftData

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var configurations: [AppConfiguration]

    var body: some View {
        NavigationStack {
            Group {
                if let configuration = configurations.first {
                    SettingsForm(configuration: configuration)
                } else {
                    ProgressView()
                        .task { await ensureConfiguration() }
                }
            }
            .navigationTitle("Settings")
        }
    }

    @MainActor
    private func ensureConfiguration() async {
        guard configurations.isEmpty else { return }
        let configuration = AppConfiguration()
        modelContext.insert(configuration)
        try? modelContext.save()
    }
}

private struct SettingsForm: View {
    @Environment(\.modelContext) private var modelContext
    @Bindable var configuration: AppConfiguration

    var body: some View {
        Form {
            Section("Notifications") {
                Toggle("Enable Notifications", isOn: $configuration.notificationsEnabled)
                    .onChange(of: configuration.notificationsEnabled) { _ in save() }

                Toggle("Use 24-hour Clock", isOn: $configuration.use24HourClock)
                    .onChange(of: configuration.use24HourClock) { _ in save() }
            }

            Section("Reminder Defaults") {
                Stepper(value: $configuration.defaultLeadTimeInHours, in: 1...168, step: 1) {
                    VStack(alignment: .leading) {
                        Text("Default lead time")
                        Text(leadTimeDescription)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                .onChange(of: configuration.defaultLeadTimeInHours) { _ in save() }
            }

            Section("Data") {
                Button(role: .destructive) {
                    resetSettings()
                } label: {
                    Label("Reset to defaults", systemImage: "arrow.counterclockwise")
                }
            }
        }
    }

    private var leadTimeDescription: String {
        let hours = Int(configuration.defaultLeadTimeInHours)
        if hours < 24 {
            return "Alerts fire \(hours) hour\(hours == 1 ? "" : "s") before the event."
        }
        let days = hours / 24
        return "Alerts fire \(days) day\(days == 1 ? "" : "s") before the event."
    }

    private func save() {
        try? modelContext.save()
    }

    private func resetSettings() {
        configuration.notificationsEnabled = true
        configuration.defaultLeadTimeInHours = 24
        configuration.use24HourClock = false
        save()
    }
}
