import SwiftUI
import SwiftData

struct PetsView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \Pet.name, order: .forward) private var pets: [Pet]
    @State private var showingAddPet = false
    @State private var selectedPet: Pet?

    var body: some View {
        NavigationStack {
            List {
                if pets.isEmpty {
                    Section {
                        ContentUnavailableView("No Pets Yet",
                                               systemImage: "pawprint",
                                               description: Text("Add your first pet to start tracking their care."))
                            .listRowSeparator(.hidden)
                            .listRowBackground(Color.clear)
                    }
                } else {
                    ForEach(pets) { pet in
                        Button {
                            selectedPet = pet
                        } label: {
                            PetCardView(pet: pet)
                                .padding(.vertical, 8)
                                .padding(.horizontal, 16)
                        }
                        .buttonStyle(.plain)
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden, edges: .all)
                    }
                    .onDelete(perform: deletePets)
                }
            }
            .listRowSeparator(.hidden, edges: .all)
            .listSectionSeparator(.hidden, edges: .all)
            .scrollContentBackground(.hidden)
            .listStyle(.plain)
            .navigationTitle("Pets")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if !pets.isEmpty {
                        EditButton()
                    }
                }
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showingAddPet = true
                    } label: {
                        Label("Add Pet", systemImage: "plus")
                    }
                }
            }
            .sheet(isPresented: $showingAddPet) {
                AddPetView()
            }
            .navigationDestination(item: $selectedPet) { pet in
                PetDetailView(pet: pet)
            }
        }
    }

    private func deletePets(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(pets[index])
            }
        }
    }
}
