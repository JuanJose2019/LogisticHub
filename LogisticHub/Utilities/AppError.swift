import Foundation

// MARK: - App Error

/// Centralized error types for the entire application.
/// Conforms to LocalizedError to provide user-facing descriptions.
enum AppError: LocalizedError, Equatable {
    
    // Networking
    case invalidURL
    case networkUnavailable
    case requestTimeout
    case serverError(statusCode: Int)
    case decodingFailed(reason: String)
    
    // Core Data
    case persistenceFailed(reason: String)
    case entityNotFound
    
    // Location
    case locationPermissionDenied
    case locationUnavailable
    
    // Generic
    case unknown(reason: String)
    
    // MARK: - LocalizedError
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return NSLocalizedString("error_invalid_url", comment: "")
        case .networkUnavailable:
            return NSLocalizedString("error_network_unavailable", comment: "")
        case .requestTimeout:
            return NSLocalizedString("error_request_timeout", comment: "")
        case .serverError(let code):
            return String(format: NSLocalizedString("error_server", comment: ""), code)
        case .decodingFailed(let reason):
            return String(format: NSLocalizedString("error_decoding", comment: ""), reason)
        case .persistenceFailed(let reason):
            return String(format: NSLocalizedString("error_persistence", comment: ""), reason)
        case .entityNotFound:
            return NSLocalizedString("error_entity_not_found", comment: "")
        case .locationPermissionDenied:
            return NSLocalizedString("error_location_permission", comment: "")
        case .locationUnavailable:
            return NSLocalizedString("error_location_unavailable", comment: "")
        case .unknown(let reason):
            return String(format: NSLocalizedString("error_unknown", comment: ""), reason)
        }
    }
    
    var recoverySuggestion: String? {
        switch self {
        case .networkUnavailable:
            return NSLocalizedString("error_recovery_network", comment: "")
        case .locationPermissionDenied:
            return NSLocalizedString("error_recovery_location", comment: "")
        default:
            return NSLocalizedString("error_recovery_generic", comment: "")
        }
    }
}
