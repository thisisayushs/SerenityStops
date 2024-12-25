//
//  SerenityStopsApp.swift
//  SerenityStops
//
//  Created by Ayush Kumar Singh on 16/12/24.
//

import SwiftUI
import SwiftData

/// SerenityStops Application Entry Point
///
/// The main application class that initializes the app's core components and configures
/// the SwiftData persistence layer.
///
/// - Important: This app requires location permissions to function properly.
/// - Note: Uses SwiftData for persistent storage of location and emotional data.
@main
struct SerenityStopsApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(container)
    }
    
    // MARK: - SwiftData Container
    
    /// Persistent storage container for the app's data model.
    /// - Note: Currently stores `LocationStore` entities.
    private let container: ModelContainer = {
        let schema = Schema([LocationStore.self])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            // FIXME: Consider implementing a more graceful error handling mechanism
            // instead of force unwrapping, which might lead to App Store rejection
            fatalError("Failed to initialize SwiftData container: \(error.localizedDescription)")
        }
    }()
}

// End of file
