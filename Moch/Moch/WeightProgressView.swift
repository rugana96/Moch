import SwiftUI
import SwiftData
import Charts
import Combine

struct WeightProgressView: View {
    let pet: Pet
    @Environment(\.modelContext) private var modelContext
    @State private var processedEntries: [WeightDatum] = []
    @State private var summary: WeightSummary?
    @State private var isLoading = true
    @State private var errorMessage: String?

    var body: some View {
        Group {
            if isLoading {
                ProgressView("Loading weight history…")
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            } else if let errorMessage {
                ContentUnavailableView("Unable to load data",
                                        systemImage: "exclamationmark.triangle",
                                        description: Text(errorMessage))
                    .padding()
            } else if processedEntries.isEmpty {
                ContentUnavailableView("No weight data",
                                        systemImage: "chart.line.uptrend.xyaxis",
                                        description: Text("Add weight entries to visualize progress."))
                    .padding()
            } else {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        let chartEntries = processedEntries
                        let showAnnotations = chartEntries.count <= 60

                        Chart(chartEntries, id: \.id) { datum in
                            if chartEntries.count > 1 {
                                LineMark(
                                    x: .value("Date", datum.recordedAt),
                                    y: .value("Weight", datum.weight)
                                )
                                .foregroundStyle(.blue)
                            }

                            PointMark(
                                x: .value("Date", datum.recordedAt),
                                y: .value("Weight", datum.weight)
                            )
                            .annotation(position: .top, alignment: .center) {
                                if showAnnotations {
                                    Text(datum.weight, format: .number.precision(.fractionLength(1)))
                                        .font(.caption2)
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                        .chartYAxisLabel("Weight (kg)")
                        .chartXAxisLabel("Date")
                        .frame(height: 240)

                        if let summary {
                            WeightSummaryView(summary: summary)
                        }
                    }
                    .padding()
                }
            }
        }
        .navigationTitle("Weight Progress")
        .task(id: pet.id) {
            await MainActor.run { loadData() }
        }
        .refreshable {
            await MainActor.run { loadData() }
        }
        .onReceive(NotificationCenter.default.publisher(for: .weightEntriesDidChange)) { notification in
            guard let updatedID = notification.userInfo?["petID"] as? UUID, updatedID == pet.id else { return }
            Task { await MainActor.run { loadData() } }
        }
    }

    @MainActor
    private func loadData() {
        isLoading = true
        errorMessage = nil

        do {
            let targetPetID = pet.id
            var descriptor = FetchDescriptor<WeightEntry>(
                predicate: #Predicate { entry in
                    entry.petID == targetPetID
                },
                sortBy: [SortDescriptor(\WeightEntry.recordedAt, order: .forward)]
            )
            descriptor.includePendingChanges = true

            let fetched = try modelContext.fetch(descriptor)
            processedEntries = fetched.map { entry in
                WeightDatum(id: entry.persistentModelID,
                            recordedAt: entry.recordedAt,
                            weight: entry.weight,
                            notes: entry.notes)
            }

            if let first = processedEntries.first, let last = processedEntries.last {
                summary = WeightSummary(start: first, end: last, change: last.weight - first.weight)
            } else {
                summary = nil
            }
        } catch {
            processedEntries = []
            summary = nil
            errorMessage = error.localizedDescription
        }

        isLoading = false
    }
}

private struct WeightSummary {
    let start: WeightDatum
    let end: WeightDatum
    let change: Double
}

private struct WeightDatum: Identifiable {
    let id: PersistentIdentifier
    let recordedAt: Date
    let weight: Double
    let notes: String?
}

private struct WeightSummaryView: View {
    let summary: WeightSummary

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Summary")
                .font(.headline)

            HStack {
                summaryTile(title: "Start",
                            date: summary.start.recordedAt,
                            weight: summary.start.weight)
                Spacer()
                summaryTile(title: "Latest",
                            date: summary.end.recordedAt,
                            weight: summary.end.weight)
            }

            let formattedChange = summary.change.formatted(.number.precision(.fractionLength(1)))
            Text("Change: \(formattedChange) kg")
                .font(.subheadline)
                .foregroundStyle(summary.change >= 0 ? .green : .red)
        }
    }

    private func summaryTile(title: String, date: Date, weight: Double) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Text(date, style: .date)
                .font(.footnote)
            Text(weight, format: .number.precision(.fractionLength(1)))
                .font(.title3.weight(.semibold))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.thinMaterial)
        )
    }
}

#Preview {
    WeightProgressPreviewWrapper()
}

private struct WeightProgressPreviewWrapper: View {
    let container: ModelContainer
    let pet: Pet

    init() {
        container = try! ModelContainer(for: Pet.self, WeightEntry.self, configurations: .init(isStoredInMemoryOnly: true))
        let context = ModelContext(container)
        let samplePet = Pet(name: "Mochi", birthday: .now, type: .dog)
        context.insert(samplePet)
        context.insert(WeightEntry(weight: 5.4, recordedAt: .now.addingTimeInterval(-86400 * 5), pet: samplePet))
        context.insert(WeightEntry(weight: 5.6, recordedAt: .now.addingTimeInterval(-86400 * 2), pet: samplePet))
        context.insert(WeightEntry(weight: 5.7, recordedAt: .now, pet: samplePet))
        pet = samplePet
    }

    var body: some View {
        NavigationStack {
            WeightProgressView(pet: pet)
        }
        .modelContainer(container)
    }
}
