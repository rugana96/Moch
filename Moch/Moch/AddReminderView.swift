import SwiftUI
import SwiftData

struct AddReminderView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Pet.name, order: .forward) private var pets: [Pet]

    @State private var title: String = ""
    @State private var type: ReminderType = .vetVisit
    @State private var scheduledDate: Date = .now
    @State private var notes: String = ""
    @State private var selectedPet: Pet?

    var body: some View {
        NavigationStack {
            Form {
                Section("Details") {
                    TextField("Title", text: $title)
                    Picker("Type", selection: $type) {
                        ForEach(ReminderType.allCases) { type in
                            Label(type.displayName, systemImage: type.symbolName)
                                .tag(type)
                        }
                    }
                    DatePicker("Date", selection: $scheduledDate, displayedComponents: [.date, .hourAndMinute])
                }

                Section("Pet") {
                    if pets.isEmpty {
                        Label("Add a pet first", systemImage: "pawprint")
                            .foregroundStyle(.secondary)
                    } else {
                        Menu {
                            Button("None") { selectedPet = nil }
                            Divider()
                            ForEach(pets) { pet in
                                Button(pet.name) {
                                    selectedPet = pet
                                }
                            }
                        } label: {
                            HStack {
                                Text(selectedPet?.name ?? "Select Pet")
                                Spacer()
                                if selectedPet != nil {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                            }
                        }
                    }
                }

                Section("Notes") {
                    TextEditor(text: $notes)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle("Add Reminder")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { save() }
                        .disabled(!canSave)
                }
            }
        }
    }

    private var canSave: Bool {
        !title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func save() {
        let cleanedTitle = title.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)
        let reminder = Reminder(title: cleanedTitle,
                                scheduledDate: scheduledDate,
                                type: type,
                                notes: cleanedNotes.isEmpty ? nil : cleanedNotes,
                                pet: selectedPet)
        modelContext.insert(reminder)
        try? modelContext.save()
        dismiss()
    }
}

#Preview {
    AddReminderView()
        .modelContainer(for: [Pet.self, Reminder.self], inMemory: true)
}
