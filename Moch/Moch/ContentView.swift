//
//  ContentView.swift
//  Moch
//
//  Created by Ruben Gago(personal) on 20/9/25.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    var body: some View {
        TabView {
            PetsView()
                .tabItem {
                    Label("Pets", systemImage: "pawprint")
                }

            RemindersView()
                .tabItem {
                    Label("Reminders", systemImage: "bell")
                }

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gearshape")
                }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Pet.self, Reminder.self, AppConfiguration.self, WeightEntry.self], inMemory: true)
}
