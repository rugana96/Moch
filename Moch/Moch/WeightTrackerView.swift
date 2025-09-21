import SwiftUI
import SwiftData

struct WeightTrackerView: View {
    @Environment(\.modelContext) private var modelContext
    let pet: Pet
    @Query private var entries: [WeightEntry]

    @State private var showingAddEntry = false
    @State private var editingEntry: WeightEntry?

    init(pet: Pet) {
        self.pet = pet
        let petID = pet.id
        _entries = Query(
            filter: #Predicate { entry in
                entry.petID == petID
            },
            sort: [SortDescriptor(\WeightEntry.recordedAt, order: .reverse)]
        )
    }

    var body: some View {
        List {
            if entries.isEmpty {
                ContentUnavailableView("No weight records",
                                        systemImage: "scalemass",
                                        description: Text("Add the first measurement to start tracking."))
                    .frame(maxWidth: .infinity)
            } else {
                ForEach(entries) { entry in
                    WeightEntryRow(entry: entry)
                        .swipeActions(edge: .trailing) {
                            Button("Edit") {
                                editingEntry = entry
                            }
                            .tint(.blue)

                            Button(role: .destructive) {
                                delete(entry)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
        }
        .navigationTitle("\(pet.name) Weight")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingAddEntry = true
                } label: {
                    Label("Add", systemImage: "plus")
                }
            }
        }
        .sheet(isPresented: $showingAddEntry) {
            WeightEntryForm(pet: pet)
        }
        .sheet(item: $editingEntry) { entry in
            WeightEntryForm(pet: pet, entry: entry)
        }
    }

    private func delete(_ entry: WeightEntry) {
        withAnimation {
            modelContext.delete(entry)
            try? modelContext.save()
            WeightEntry.notifyChange(for: pet.id)
        }
    }
}

private struct WeightEntryRow: View {
    @Bindable var entry: WeightEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(entry.recordedAt, style: .date)
                    .font(.headline)
                Spacer()
                Text(entry.weight, format: .number.precision(.fractionLength(1)))
                    .font(.title3.weight(.semibold))
                    .foregroundStyle(.primary)
                    .accessibilityLabel("Weight: \(entry.weight.formatted()) kilograms")
            }

            if let notes = entry.notes, !notes.isEmpty {
                Text(notes)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding(.vertical, 8)
    }
}
