import SwiftUI
import MapKit
import SwiftData

/// ViewModel class that manages map-related functionality and location services.
/// Conforms to CLLocationManagerDelegate to handle location updates and permissions.
class MapViewModel: NSObject, ObservableObject, CLLocationManagerDelegate {
    // MARK: - Published Properties
    
    /// The current position of the map camera
    @Published var position: MapCameraPosition
    /// Array of location annotations displayed on the map
    @Published var annotations: [LocationAnnotation] = []
    /// Controls the visibility of the location input sheet
    @Published var showLocationSheet = false
    /// Stores the coordinate of the last tapped location
    @Published var tappedCoordinate: CLLocationCoordinate2D?
    /// User's description of the location
    @Published var locationDescription: String = ""
    /// The sentiment label derived from the location description
    @Published var sentimentLabel: String = ""
    
    /// Added Alert Properties
    @Published var showLocationAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    
    /// Added properties for statistics
    @Published var moodSummary: [String: Int] = [:]  // Counts of each mood type
    @Published var mostFrequentMood: String = ""     // Most common mood
    @Published var recentMoods: [LocationAnnotation] = []  // Recent mood entries
    
    // MARK: - Private Properties
    private let locationManager: CLLocationManager
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    private var modelContext: ModelContext?
    
    // MARK: - Initialization
    override init() {
        locationManager = CLLocationManager()
        position = .region(
            MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 34.0736, longitude: -118.4004),
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        )
        
        super.init()
        
        locationManager.delegate = self
        authorizationStatus = locationManager.authorizationStatus
    }
    
    // MARK: - SwiftData Methods
    
    /// Sets up the SwiftData model context
    /// - Parameter context: The SwiftData model context
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        loadStoredLocations()
    }
    
    /// Loads stored locations from SwiftData
    private func loadStoredLocations() {
        guard let context = modelContext else { return }
        
        do {
            let descriptor = FetchDescriptor<LocationStore>()
            let storedLocations = try context.fetch(descriptor)
            annotations = storedLocations.map { store in
                LocationAnnotation(
                    coordinate: store.coordinate,
                    label: store.label,
                    createdAt: store.createdAt
                )
            }
            updateMoodStatistics()
        } catch {
            print("Error loading locations: \(error)")
        }
    }
    
    // MARK: - Location Permission Methods
    
    /// Requests location permission if not already determined
    func requestLocationPermission() {
        if locationManager.authorizationStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    /// Handles tap on location button when permission is denied
    func handleLocationButtonTap() {
        switch locationManager.authorizationStatus {
        case .denied, .restricted:
            alertTitle = "Location Access Required"
            alertMessage = "Please enable location access in Settings to use this feature."
            showLocationAlert = true
            
        case .notDetermined:
            requestLocationPermission()
            
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
            
        @unknown default:
            break
        }
    }
    
    // MARK: - CLLocationManagerDelegate Methods
    
    /// Handles changes in location authorization status
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        switch authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        default:
            break
        }
    }
    
    /// Handles location updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first?.coordinate else { return }
        
        position = .region(
            MKCoordinateRegion(
                center: location,
                span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
            )
        )
        
        locationManager.stopUpdatingLocation()
    }
    // MARK: - Annotation Methods
    
    /// Adds a new annotation to the map and persists it
    /// - Parameters:
    ///   - coordinate: The location coordinate
    ///   - label: The sentiment label for the annotation
    func addAnnotation(_ coordinate: CLLocationCoordinate2D, label: String) {
        let timestamp = Date()
        let annotation = LocationAnnotation(
            coordinate: coordinate,
            label: label,
            createdAt: timestamp
        )
        annotations.append(annotation)
        
        // Persist to SwiftData
        guard let context = modelContext else { return }
        let locationStore = LocationStore(coordinate: coordinate, label: label)
        context.insert(locationStore)
        
        do {
            try context.save()
            updateMoodStatistics()  // Update statistics after successful save
        } catch {
            print("Error saving location: \(error)")
        }
    }
    
    /// Handles tap events on the map
    /// - Parameter coordinate: The tapped location coordinate
    
    func handleMapTap(at coordinate: CLLocationCoordinate2D) {
        tappedCoordinate = coordinate
        showLocationSheet = true
        locationDescription = ""
        sentimentLabel = ""
    }
    
    /// Handles the submission of a new annotation
    func handleAnnotationSubmission() {
       
        guard let coordinate = tappedCoordinate, !locationDescription.isEmpty else { return }
        addAnnotation(coordinate, label: sentimentLabel)
        feedbackGenerator.notificationOccurred(.success)
        showLocationSheet = false
            
    }
    
    // MARK: - Deletion Method
    
    /// Deletes an annotation from both the UI and persistent storage
    /// - Parameter index: The index of the annotation to delete
    func deleteAnnotation(at index: Int) {
        guard let context = modelContext else { return }
        
        let annotationToDelete = annotations[index]
        annotations.remove(at: index)
        
        let lat = annotationToDelete.coordinate.latitude
        let lon = annotationToDelete.coordinate.longitude
        
        // Find and delete the matching LocationStore object
        do {
            let descriptor = FetchDescriptor<LocationStore>()
            let storedLocations = try context.fetch(descriptor)
            
            // Find and delete matching location
            for location in storedLocations {
                if location.latitude == lat && location.longitude == lon {
                    context.delete(location)
                }
            }
            
            try context.save()
            feedbackGenerator.notificationOccurred(.success)
            updateMoodStatistics()
        } catch {
            print("Error deleting location: \(error)")
            feedbackGenerator.notificationOccurred(.error)
        }
    }
    
    // MARK: - Added Methods
    
    /// Zooms the map to a specific coordinate with animation
    /// - Parameter coordinate: The coordinate to zoom to
    func zoomToLocation(_ coordinate: CLLocationCoordinate2D) {
        withAnimation(.easeInOut(duration: 0.5)) {
            position = .camera(MapCamera(
                centerCoordinate: coordinate,
                distance: 500,  // Sets zoom level - lower number = closer zoom
                heading: 0,     // Keep default heading
                pitch: 60       // Tilt the view for better perspective
            ))
        }
    }
    
    /// Updates mood statistics based on current annotations
    private func updateMoodStatistics() {
        // Reset statistics
        moodSummary.removeAll()
        
        // Count occurrences of each mood
        for annotation in annotations {
            moodSummary[annotation.label, default: 0] += 1
        }
        
        // Find most frequent mood
        if let mostCommon = moodSummary.max(by: { $0.value < $1.value }) {
            mostFrequentMood = mostCommon.key
        }
        
        // Get recent moods (last 5 entries)
        recentMoods = Array(annotations.sorted { $0.createdAt > $1.createdAt }.prefix(5))
    }
}
