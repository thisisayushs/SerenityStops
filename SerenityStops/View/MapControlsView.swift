//
//  MapControlsView.swift
//  SerenityStops
//
//  Created by Ayush Kumar Singh on 17/12/24.
//

import SwiftUI
import MapKit

/// A view that contains the map controls based on location authorization status
struct MapControlsView: View {
    // MARK: - Properties
    let authStatus: CLAuthorizationStatus
    let onLocationTap: () -> Void
    
    var body: some View {
        Group {
            if authStatus == .authorizedWhenInUse || authStatus == .authorizedAlways {
                MapUserLocationButton()
            } else {
                Button(action: onLocationTap) {
                    Image(systemName: "location.fill")
                        .imageScale(.large)
                }
                .buttonStyle(.plain)
                .padding(8)
                .background(.thinMaterial)
                .cornerRadius(8)
            }
            MapCompass()
        }
    }
}

// End of file

