//
//  SerenityStopsApp.swift
//  SerenityStops
//
//  Created by Ayush Kumar Singh on 16/12/24.
//

import SwiftUI
import SwiftData

/// The main entry point of the SerenityStops application.
/// This app allows users to mark locations on a map and associate their emotional experiences with those places.
@main
struct SerenityStopsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
    
    // MARK: - SwiftData Container
    
    let container: ModelContainer = {
        let schema = Schema([LocationStore.self])
        let modelConfiguration = ModelConfiguration(schema: schema)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not initialize SwiftData container: \(error)")
        }
    }()
}

// End of file
