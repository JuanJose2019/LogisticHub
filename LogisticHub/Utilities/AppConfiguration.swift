import Foundation

// MARK: - App Configuration

enum AppConfiguration {
    
    // MARK: - API
    static let baseURL = "https://api.logistichubs.sv/v1"
    static let apiTimeout: TimeInterval = 30
    
    // MARK: - Map
    static let defaultMapSpan: Double = 0.05  // degrees (zoom level)
    static let hubAnnotationSize: Double = 40
    
    // MARK: - UI
    static let listRowHeight: CGFloat = 80
    static let cornerRadius: CGFloat = 12
    static let shadowRadius: CGFloat = 4
    
    // MARK: - Pagination
    static let pageSize: Int = 20
    
    // MARK: - Cache
    static let cacheExpiryHours: Int = 24
}
