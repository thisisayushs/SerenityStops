
//  LocationStore.swift
//  SerenityStops
//
//  Created by Ayush Kumar Singh on 17/12/24.

import Foundation
import SwiftData
import CoreLocation

@Model
class LocationStore {
    // MARK: - Properties
    
    /// Unique identifier for the location
    var id: UUID
    /// The latitude of the location
    var latitude: Double
    /// The longitude of the location
    var longitude: Double
    /// The sentiment label associated with this location
    var label: String
    /// Timestamp when the location was created
    var createdAt: Date
    
    // MARK: - Initialization
    
    init(id: UUID = UUID(), coordinate: CLLocationCoordinate2D, label: String) {
        self.id = id
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.label = label
        self.createdAt = Date()
    }
    
    // MARK: - Helper Methods
    
    /// Converts stored coordinates to CLLocationCoordinate2D
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}

// End of file

