import Foundation
import CoreLocation

// MARK: - Location Service Protocol

protocol LocationServiceProtocol {
    func requestLocation() async throws -> CLLocationCoordinate2D
}

// MARK: - Location Service Implementation

final class LocationService: NSObject, LocationServiceProtocol, CLLocationManagerDelegate {
    
    // MARK: - Properties
    private let manager = CLLocationManager()
    private var continuation: CheckedContinuation<CLLocationCoordinate2D, Error>?
    
    // MARK: - Init
    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
    }
    
    // MARK: - Public
    
    func requestLocation() async throws -> CLLocationCoordinate2D {
        return try await withCheckedThrowingContinuation { continuation in
            self.continuation = continuation
            
            switch manager.authorizationStatus {
            case .notDetermined:
                manager.requestWhenInUseAuthorization()
            case .authorizedWhenInUse, .authorizedAlways:
                manager.requestLocation()
            case .denied, .restricted:
                resumeContinuation(throwing: AppError.locationPermissionDenied)
            @unknown default:
                resumeContinuation(throwing: AppError.locationUnavailable)
            }
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else {
            resumeContinuation(throwing: AppError.locationUnavailable)
            return
        }
        resumeContinuation(returning: location.coordinate)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        resumeContinuation(throwing: AppError.locationUnavailable)
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.requestLocation()
        case .denied, .restricted:
            resumeContinuation(throwing: AppError.locationPermissionDenied)
        default:
            break
        }
    }
    
    private func resumeContinuation(returning coordinate: CLLocationCoordinate2D? = nil, throwing error: Error? = nil) {
        if let error = error {
            continuation?.resume(throwing: error)
        } else if let coordinate = coordinate {
            continuation?.resume(returning: coordinate)
        }
        continuation = nil
    }
}
