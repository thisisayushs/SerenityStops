//
//  LocationAnnotation.swift
//  SerenityStops
//
//  Created by Ayush Kumar Singh on 17/12/24.
//

import Foundation

import MapKit

/// A model representing a location annotation on the map.
/// Each annotation contains:
/// - A unique identifier
/// - Geographic coordinates
/// - A sentiment label describing the user's feelings at that location

struct LocationAnnotation: Identifiable {
    
    /// Unique identifier for the annotation
    let id = UUID()
    /// The geographic coordinates of the annotation
    let coordinate: CLLocationCoordinate2D
    /// The sentiment label associated with this location
    let label: String
}
// End of file

