import SwiftUI
import MapKit
import SwiftData

/// ViewModel class that manages map-related functionality and location services.
/// Conforms to CLLocationManagerDelegate to handle location updates and permissions.
@MainActor
final class MapViewModel: NSObject, ObservableObject {
    // MARK: - Published Properties
    
    /// The current position of the map camera.
    @Published var position: MapCameraPosition
    
    /// Array of location annotations displayed on the map
    @Published private(set) var annotations: [LocationAnnotation] = []
    
    /// Controls the visibility of the location input sheet
    @Published var showLocationSheet = false
    
    /// The coordinate of the last tapped location
    @Published var tappedCoordinate: CLLocationCoordinate2D?
    
    /// User's description of the location
    @Published var locationDescription = "" {
        didSet {
            updateSentimentLabel()
        }
    }
    
    /// The sentiment label derived from the location description
    @Published var sentimentLabel = ""
    
    /// Added Alert Properties
    @Published var showLocationAlert = false
    @Published var alertTitle = ""
    @Published var alertMessage = ""
    
    @Published private(set) var authorizationStatus: CLAuthorizationStatus
    
    /// Added properties for statistics
    @Published private(set) var moodSummary: [String: Int] = [:]  // Counts of each mood type
    @Published private(set) var mostFrequentMood = ""     // Most common mood
    @Published private(set) var recentMoods: [LocationAnnotation] = []  // Recent mood entries
    
    // MARK: - Private Properties
    private let locationManager: CLLocationManager
    private let feedbackGenerator = UINotificationFeedbackGenerator()
    private let analyzer = Analyzer.shared
    private var modelContext: ModelContext?
    
    // MARK: - Initialization
    override init() {
        locationManager = CLLocationManager()
        position = .userLocation(fallback: .automatic)
        authorizationStatus = locationManager.authorizationStatus
        
        super.init()
        
        locationManager.delegate = self
        setupInitialPosition()
    }
    
    // MARK: - Private Setup Methods
    
    private func setupInitialPosition() {
        // Default to a central location if user location is not available
        let defaultRegion = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 34.0736, longitude: -118.4004),
            span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
        )
        position = .region(defaultRegion)
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
            handleStorageError(error)
        }
    }
    
    // MARK: - Location Permission Methods
    
    /// Requests location permission if not already determined
    func requestLocationPermission() {
        guard authorizationStatus == .notDetermined else { return }
        locationManager.requestWhenInUseAuthorization()
    }
    
    /// Handles tap on location button when permission is denied
    func handleLocationButtonTap() {
        switch authorizationStatus {
        case .denied, .restricted:
            showLocationServicesAlert()
        case .notDetermined:
            requestLocationPermission()
        case .authorizedWhenInUse, .authorizedAlways:
            locationManager.startUpdatingLocation()
        @unknown default:
            break
        }
    }
    
    // MARK: - Annotation Methods
    
    /// Adds a new annotation to the map and persists it
    /// - Parameters:
    ///   - coordinate: The location coordinate
    ///   - label: The sentiment label for the annotation
    func addAnnotation(_ coordinate: CLLocationCoordinate2D, label: String) {
        let annotation = LocationAnnotation(
            coordinate: coordinate,
            label: label,
            createdAt: Date()
        )
        
        do {
            try persistAnnotation(annotation)
            annotations.append(annotation)
            updateMoodStatistics()
        } catch {
            handleStorageError(error)
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
        guard let coordinate = tappedCoordinate,
              !locationDescription.isEmpty,
              !sentimentLabel.isEmpty else {
            showValidationAlert()
            return
        }
        
        addAnnotation(coordinate, label: sentimentLabel)
        feedbackGenerator.notificationOccurred(.success)
        showLocationSheet = false
    }
    
    // MARK: - Deletion Method
    
    /// Deletes an annotation from both the UI and persistent storage
    /// - Parameter index: The index of the annotation to delete
    func deleteAnnotation(at index: Int) {
        guard index < annotations.count else { return }
        
        do {
            try deleteAnnotationFromStorage(at: index)
            feedbackGenerator.notificationOccurred(.success)
        } catch {
            feedbackGenerator.notificationOccurred(.error)
            handleDeletionError(error)
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
    
    // MARK: - Private Methods
    
    private func updateSentimentLabel() {
        sentimentLabel = analyzer.mapSentiment(from: locationDescription)
    }
    
    private func showValidationAlert() {
        alertTitle = "Invalid Input"
        alertMessage = "Please provide a description for this location."
        showLocationAlert = true
    }
    
    private func showLocationServicesAlert() {
        alertTitle = "Location Access Required"
        alertMessage = "Please enable location access in Settings to use this feature."
        showLocationAlert = true
    }
    
    private func handleDeletionError(_ error: Error) {
        alertTitle = "Deletion Error"
        alertMessage = "Failed to delete location: \(error.localizedDescription)"
        showLocationAlert = true
    }
    
    private func persistAnnotation(_ annotation: LocationAnnotation) throws {
        guard let context = modelContext else {
            throw StorageError.contextMissing
        }
        
        let locationStore = LocationStore(
            coordinate: annotation.coordinate,
            label: annotation.label
        )
        context.insert(locationStore)
        try context.save()
    }
    
    private func deleteAnnotationFromStorage(at index: Int) throws {
        guard let context = modelContext else {
            throw StorageError.contextMissing
        }
        
        let annotationToDelete = annotations[index]
        let descriptor = FetchDescriptor<LocationStore>()
        let storedLocations = try context.fetch(descriptor)
        
        guard let matchingLocation = storedLocations.first(where: { location in
            location.latitude == annotationToDelete.coordinate.latitude &&
            location.longitude == annotationToDelete.coordinate.longitude
        }) else {
            throw StorageError.locationNotFound
        }
        
        context.delete(matchingLocation)
        try context.save()
        annotations.remove(at: index)
        updateMoodStatistics()
    }
    
    private func updateMoodStatistics() {
        moodSummary = annotations.reduce(into: [:]) { summary, annotation in
            summary[annotation.label, default: 0] += 1
        }
        
        mostFrequentMood = moodSummary
            .max(by: { $0.value < $1.value })?
            .key ?? ""
        
        recentMoods = Array(
            annotations
                .sorted { $0.createdAt > $1.createdAt }
                .prefix(5)
        )
    }
    
    private func handleStorageError(_ error: Error) {
        alertTitle = "Storage Error"
        alertMessage = error.localizedDescription
        showLocationAlert = true
    }
}

extension MapViewModel: CLLocationManagerDelegate {
    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
            
            if self.authorizationStatus == .authorizedWhenInUse ||
                self.authorizationStatus == .authorizedAlways {
                manager.startUpdatingLocation()
            }
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first?.coordinate else { return }
        
        Task { @MainActor in
            withAnimation {
                self.position = .region(
                    MKCoordinateRegion(
                        center: location,
                        span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)
                    )
                )
            }
            manager.stopUpdatingLocation()
        }
    }
}

private enum StorageError: LocalizedError {
    case contextMissing, locationNotFound
    
    var errorDescription: String? {
        switch self {
        case .contextMissing: return "Storage context is not available"
        case .locationNotFound: return "Location not found in storage"
        }
    }
}
