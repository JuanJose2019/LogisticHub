import Foundation
import CoreLocation

// MARK: - Hub Domain Model

/// Represents a logistics hub with all its properties.
/// This is the pure domain model, decoupled from Core Data and networking layers.
struct Hub: Identifiable, Equatable, Hashable {
    
    // MARK: - Properties
    let id: UUID
    let name: String
    let address: String
    let city: String
    let country: String
    let latitude: Double
    let longitude: Double
    let capacity: Int
    let type: HubType
    let status: HubStatus
    let contactEmail: String
    let phoneNumber: String
    let createdAt: Date
    
    // MARK: - Computed Properties
    
    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }
    
    var fullAddress: String {
        "\(address), \(city), \(country)"
    }
    
    var formattedCapacity: String {
        capacity.formatted(.number)
    }
}

// MARK: - Hub Type

enum HubType: String, CaseIterable, Codable {
    case distribution  = "distribution"
    case storage       = "storage"
    case crossdocking  = "crossdocking"
    case fulfillment   = "fulfillment"
    
    var localizedName: String {
        switch self {
        case .distribution:  return NSLocalizedString("hub_type_distribution", comment: "")
        case .storage:       return NSLocalizedString("hub_type_storage", comment: "")
        case .crossdocking:  return NSLocalizedString("hub_type_crossdocking", comment: "")
        case .fulfillment:   return NSLocalizedString("hub_type_fulfillment", comment: "")
        }
    }
    
    var systemIcon: String {
        switch self {
        case .distribution:  return "shippingbox.fill"
        case .storage:       return "archivebox.fill"
        case .crossdocking:  return "arrow.left.arrow.right"
        case .fulfillment:   return "checkmark.seal.fill"
        }
    }
}

// MARK: - Hub Status

enum HubStatus: String, CaseIterable, Codable {
    case active   = "active"
    case inactive = "inactive"
    case maintenance = "maintenance"
    
    var localizedName: String {
        switch self {
        case .active:       return NSLocalizedString("hub_status_active", comment: "")
        case .inactive:     return NSLocalizedString("hub_status_inactive", comment: "")
        case .maintenance:  return NSLocalizedString("hub_status_maintenance", comment: "")
        }
    }
    
    var color: String {
        switch self {
        case .active:       return "green"
        case .inactive:     return "red"
        case .maintenance:  return "orange"
        }
    }
}
