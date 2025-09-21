import SwiftUI
import SwiftData

struct WeightEntryForm: View {
    enum Mode {
        case add
        case edit

        var title: String {
            switch self {
            case .add: return "Add Weight"
            case .edit: return "Edit Weight"
            }
        }
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    private let pet: Pet
    private let mode: Mode
    private let entry: WeightEntry?

    @State private var weight: Double
    @State private var recordedAt: Date
    @State private var notes: String

    init(pet: Pet, entry: WeightEntry? = nil) {
        self.pet = pet
        self.entry = entry
        self.mode = entry == nil ? .add : .edit
        _weight = State(initialValue: entry?.weight ?? 5.0)
        _recordedAt = State(initialValue: entry?.recordedAt ?? .now)
        _notes = State(initialValue: entry?.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Measurement") {
                    HStack {
                        TextField("Weight", value: $weight, format: .number)
                            .keyboardType(.decimalPad)
                        Text("kg")
                            .foregroundStyle(.secondary)
                    }

                    DatePicker("Date", selection: $recordedAt, displayedComponents: .date)
                }

                Section("Notes") {
                    TextField("Optional notes", text: $notes, axis: .vertical)
                        .lineLimit(1...4)
                }
            }
            .navigationTitle(mode.title)
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
        weight > 0
    }

    private func save() {
        let trimmedNotes = notes.trimmingCharacters(in: .whitespacesAndNewlines)

        if let entry {
            entry.weight = weight
            entry.recordedAt = recordedAt
            entry.notes = trimmedNotes.isEmpty ? nil : trimmedNotes
            entry.updatedAt = .now
        } else {
            let newEntry = WeightEntry(weight: weight,
                                       recordedAt: recordedAt,
                                       notes: trimmedNotes.isEmpty ? nil : trimmedNotes,
                                       pet: pet)
            modelContext.insert(newEntry)
        }

        try? modelContext.save()
        WeightEntry.notifyChange(for: pet.id)
        dismiss()
    }
}
