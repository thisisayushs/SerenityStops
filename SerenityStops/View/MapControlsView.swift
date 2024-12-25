//
//  MapControlsView.swift
//  SerenityStops
//
//  Created by Ayush Kumar Singh on 17/12/24.
//

import SwiftUI
import MapKit

/// A view that provides map control buttons based on location authorization status.
///
/// This view manages:
/// - Location button display based on authorization status
/// - Map compass display
/// - User interaction with location services
///
/// - Important: Appearance changes based on location authorization status
/// - Note: Uses system materials for visual consistency
struct MapControlsView: View {
    // MARK: - Properties
    
    /// The current location authorization status
    let authStatus: CLAuthorizationStatus
    
    /// Callback triggered when the location button is tapped
    let onLocationTap: () -> Void
    
    // MARK: - Private Properties
    
    private let buttonSize: CGFloat = 44
    private let cornerRadius: CGFloat = 8
    private let padding: CGFloat = 8
    
    // MARK: - View Components
    
    /// Location button based on authorization status
    @ViewBuilder
    private var locationButton: some View {
        if authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways {
            MapUserLocationButton()
                .accessibilityLabel("Show current location")
        } else {
            Button(action: onLocationTap) {
                Image(systemName: "location.fill")
                    .imageScale(.large)
            }
            .buttonStyle(.plain)
            .frame(width: buttonSize, height: buttonSize)
            .padding(padding)
            .background(.thinMaterial)
            .cornerRadius(cornerRadius)
            .accessibilityLabel("Enable location services")
            .accessibilityHint("Tap to request location permission")
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(spacing: padding) {
            locationButton
            
            MapCompass()
                .mapControlVisibility(.visible)
                .accessibilityLabel("Map compass")
        }
    }
}

// End of file
