import SwiftUI
import SwiftData

struct PetDetailView: View {
    let pet: Pet
    @Query private var reminders: [Reminder]
    @State private var showingWeightTracker = false

    init(pet: Pet) {
        self.pet = pet
        let petID = pet.persistentModelID
        _reminders = Query(filter: #Predicate { reminder in
            reminder.pet?.persistentModelID == petID
        }, sort: [SortDescriptor(\Reminder.scheduledDate, order: .forward)])
    }

    var body: some View {
        List {
            Section("Profile") {
                LabeledContent("Name", value: pet.name)
                LabeledContent("Birthday") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(pet.birthday, style: .date)
                        Text(pet.birthday, style: .relative)
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                }
                LabeledContent("Type", value: pet.type.displayName)
            }

            Section("Weight") {
                Button {
                    showingWeightTracker = true
                } label: {
                    Label("Manage Weight Entries", systemImage: "scalemass")
                }

                NavigationLink {
                    WeightProgressView(pet: pet)
                } label: {
                    Label("View Weight Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
            }

            Section("Reminders") {
                if reminders.isEmpty {
                    ContentUnavailableView("No reminders",
                                            systemImage: "bell.slash",
                                            description: Text("Create reminders to keep track of vet visits and vaccines."))
                        .frame(maxWidth: .infinity)
                } else {
                    ForEach(reminders) { reminder in
                        ReminderRow(reminder: reminder)
                    }
                }
            }
        }
        .navigationTitle(pet.name)
        .sheet(isPresented: $showingWeightTracker) {
            NavigationStack {
                WeightTrackerView(pet: pet)
            }
        }
    }
}
