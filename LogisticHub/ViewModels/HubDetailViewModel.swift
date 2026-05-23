import Foundation
import MapKit
import CoreLocation

// MARK: - Hub Detail ViewModel

@MainActor
final class HubDetailViewModel: ObservableObject {
    
    // MARK: - Published State
    @Published var mapRegion: MKCoordinateRegion
    @Published private(set) var isLoadingRoute: Bool = false
    @Published private(set) var userLocation: CLLocationCoordinate2D?
    @Published var showDirections: Bool = false
    
    // MARK: - Properties
    let hub: Hub
    
    var annotationItems: [HubAnnotationItem] {
        [HubAnnotationItem(hub: hub)]
    }
    
    var formattedCoordinates: String {
        String(format: "%.4f° N, %.4f° W", hub.latitude, abs(hub.longitude))
    }
    
    var googleMapsURL: URL? {
        let query = "\(hub.latitude),\(hub.longitude)"
        return URL(string: "https://maps.google.com/?q=\(query)")
    }
    
    var wazeURL: URL? {
        URL(string: "waze://?ll=\(hub.latitude),\(hub.longitude)&navigate=yes")
    }
    
    // MARK: - Dependencies
    private let locationService: LocationServiceProtocol
    
    // MARK: - Init
    init(
        hub: Hub,
        locationService: LocationServiceProtocol = LocationService()
    ) {
        self.hub = hub
        self.locationService = locationService
        
        self.mapRegion = MKCoordinateRegion(
            center: hub.coordinate,
            span: MKCoordinateSpan(
                latitudeDelta: AppConfiguration.defaultMapSpan,
                longitudeDelta: AppConfiguration.defaultMapSpan
            )
        )
    }
    
    // MARK: - Intents
    
    func requestUserLocation() {
        Task { @MainActor in
            do {
                self.userLocation = try await locationService.requestLocation()
            } catch {
                // Fail silently; map still shows hub
            }
        }
    }
    
    func centerOnHub() {
        withAnimation {
            mapRegion = MKCoordinateRegion(
                center: hub.coordinate,
                span: MKCoordinateSpan(
                    latitudeDelta: AppConfiguration.defaultMapSpan,
                    longitudeDelta: AppConfiguration.defaultMapSpan
                )
            )
        }
    }
    
    func openInMaps() {
        let mapItem = MKMapItem(placemark: MKPlacemark(coordinate: hub.coordinate))
        mapItem.name = hub.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

// MARK: - Hub Annotation Item

struct HubAnnotationItem: Identifiable {
    let id: UUID
    let coordinate: CLLocationCoordinate2D
    let title: String
    let subtitle: String
    let type: HubType
    
    init(hub: Hub) {
        self.id = hub.id
        self.coordinate = hub.coordinate
        self.title = hub.name
        self.subtitle = hub.city
        self.type = hub.type
    }
}
