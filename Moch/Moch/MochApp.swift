//
//  MochApp.swift
//  Moch
//
//  Created by Ruben Gago(personal) on 20/9/25.
//

import SwiftUI
import SwiftData

@main
struct MochApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Pet.self,
            Reminder.self,
            AppConfiguration.self,
            WeightEntry.self
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
