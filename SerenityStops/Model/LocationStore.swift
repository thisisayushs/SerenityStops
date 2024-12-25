//  LocationStore.swift
//  SerenityStops
//
//  Created by Ayush Kumar Singh on 17/12/24.

import Foundation
import SwiftData
import CoreLocation

/// A model class representing a location with associated emotional sentiment.
///
/// This class stores geographical coordinates and emotional data for locations marked by users.
/// It uses SwiftData for persistent storage and integrates with CoreLocation for coordinate handling.
///
/// - Important: This class is marked with @Model for SwiftData persistence.
/// - Note: All properties are persisted automatically by SwiftData.
@Model
final class LocationStore {
    // MARK: - Properties
    
    /// Unique identifier for the location entry.
    ///
    /// This ID is used to differentiate between different location entries and
    /// is automatically generated during initialization if not provided.
    private(set) var id: UUID
    /// The geographical latitude of the marked location.
    ///
    /// Valid range is -90.0 to 90.0 degrees.
    private(set) var latitude: Double
    /// The geographical longitude of the marked location.
    ///
    /// Valid range is -180.0 to 180.0 degrees.
    private(set) var longitude: Double
    /// The emotional sentiment label associated with this location.
    ///
    /// This represents the user's emotional state or experience at this location.
    var label: String
    /// The timestamp when this location entry was created.
    ///
    /// This property is automatically set during initialization.
    private(set) var createdAt: Date
    
    // MARK: - Initialization
    
    /// Creates a new location store entry.
    /// - Parameters:
    ///   - id: A unique identifier for the location. Defaults to a new UUID.
    ///   - coordinate: The geographical coordinate of the location.
    ///   - label: The emotional sentiment label for this location.
    init(id: UUID = UUID(), coordinate: CLLocationCoordinate2D, label: String) {
        precondition(CLLocationCoordinate2DIsValid(coordinate),
                     "Invalid coordinate provided: \(coordinate)")
        
        self.id = id
        self.latitude = coordinate.latitude
        self.longitude = coordinate.longitude
        self.label = label
        self.createdAt = Date()
    }
    
    // MARK: - Computed Properties
    
    /// Converts stored coordinates to CLLocationCoordinate2D
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
}
