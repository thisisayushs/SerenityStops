//  ContentView.swift
//  SerenityStops
//
//  Created by Ayush Kumar Singh on 16/12/24.
//

import SwiftUI
import MapKit
import TipKit
import SwiftData

/// Global analyzer instance for sentiment analysis

let analyzer = Analyzer()

/// The main view of the application that displays the map and handles user interactions.
/// This view is responsible for:
/// - Displaying the map with location annotations
/// - Handling map interactions
/// - Showing location input sheets
/// - Managing tips and user guidance

struct ContentView: View {
    
    /// View model that handles map-related logic and state
    @StateObject private var viewModel = MapViewModel()
    @Environment(\.modelContext) private var modelContext
    
    // MARK: - Body
    
    var body: some View {
        MapReader { proxy in
            ZStack {
                
                // MARK: - Map View
                Map(position: $viewModel.position) {
                    ForEach(viewModel.annotations.indices, id: \.self) { index in
                        let annotation = viewModel.annotations[index]
                        Annotation("", coordinate: annotation.coordinate) {
                            MapAnnotationView(
                                annotation: annotation,
                                index: index,
                                onDelete: { viewModel.deleteAnnotation(at: index) },
                                onTap: { viewModel.zoomToLocation(annotation.coordinate) }
                            )
                        }
                    }
                }
                .mapStyle(.standard(elevation: .realistic))
                .mapControls {
                    MapControlsView(
                        authStatus: viewModel.authorizationStatus,
                        onLocationTap: viewModel.handleLocationButtonTap
                    )
                }
                
                // MARK: - Tips View
                VStack {
                    if viewModel.annotations.isEmpty {
                        TipView(MapTapTip())
                            .padding()
                            .task {
                                await MapTapTip.mapTipDisplayed.donate()
                            }
                    } else if viewModel.annotations.count == 1 {
                        TipView(DeleteAnnotationTip())
                            .padding()
                    }
                    Spacer()
                }
            }
            // MARK: - Gesture Handlers
            .onTapGesture { screenCoord in
                if let coordinate = proxy.convert(screenCoord, from: .local) {
                    viewModel.handleMapTap(at: coordinate)
                }
            }
            // MARK: - Location Sheet
            
            .sheet(isPresented: $viewModel.showLocationSheet) {
                if let coordinate = viewModel.tappedCoordinate {
                    LocationSheet(
                        isPresented: $viewModel.showLocationSheet,
                        locationDescription: $viewModel.locationDescription,
                        sentimentLabel: $viewModel.sentimentLabel,
                        coordinate: coordinate,
                        onSubmit: viewModel.handleAnnotationSubmission
                    ).transition(.move(edge: .bottom).combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.5), value: viewModel.showLocationSheet)
                }
            }
            // MARK: - Location Alert
            .alert(viewModel.alertTitle,
                   isPresented: $viewModel.showLocationAlert) {
                Button("Open Settings") {
                    if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(settingsURL)
                    }
                }
                Button("Cancel", role: .cancel) {}
            } message: {
                Text(viewModel.alertMessage)
            }
        }
        // MARK: - Lifecycle Methods
        
        .task {
            try? Tips.configure([
                .displayFrequency(.immediate),
                .datastoreLocation(.applicationDefault)
            ])
        }
        
        .onAppear {
            viewModel.setModelContext(modelContext)
            viewModel.requestLocationPermission()
        }
    }
}
// MARK: - Preview

#Preview {
    ContentView()
        .modelContainer(for: LocationStore.self)
}
