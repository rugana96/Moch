//
//  ContentView.swift
//  Moch
//
//  Created by Ruben Gago(personal) on 20/9/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var pets: [Pet]
    @State private var showingAddPet = false
    
    var body: some View {
        NavigationSplitView {
            List {
                ForEach(pets) { pet in
                    PetCardView(pet: pet)
                        .listRowSeparator(.hidden)
                }
                .onDelete(perform: deletePets)
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    EditButton()
                }
                ToolbarItem {
                    Button {
                        showingAddPet = true
                    } label: {
                        Label("Add Pet", systemImage: "plus")
                    }
                }
            }
            .listStyle(.plain)
            .sheet(isPresented: $showingAddPet) {
                AddPetView()
            }
        } detail: {
            Text("Select an item")
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

#Preview {
    ContentView()
        .modelContainer(for: Pet.self, inMemory: true)
}
