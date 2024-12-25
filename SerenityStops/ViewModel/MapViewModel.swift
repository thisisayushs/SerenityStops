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
                LocationAnnotation(coordinate: store.coordinate, label: store.label)
            }
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
    
    // MARK: - CLLocationManagerDelegate Methods
    
    /// Handles changes in location authorization status
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
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
        let annotation = LocationAnnotation(coordinate: coordinate, label: label)
        annotations.append(annotation)
        
        // Persist to SwiftData
        guard let context = modelContext else { return }
        let locationStore = LocationStore(coordinate: coordinate, label: label)
        context.insert(locationStore)
        
        do {
            try context.save()
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
}
