import Foundation

// MARK: - Hub DTO (Data Transfer Object)

/// Decodable struct that mirrors the JSON API response.
/// Kept separate from the domain model to isolate networking concerns.
struct HubDTO: Decodable {
    let id: String
    let name: String
    let address: String
    let city: String
    let country: String
    let latitude: Double
    let longitude: Double
    let capacity: Int
    let type: String
    let status: String
    let contactEmail: String
    let phoneNumber: String
    let createdAt: String
    
    // MARK: - Coding Keys
    enum CodingKeys: String, CodingKey {
        case id, name, address, city, country
        case latitude, longitude, capacity, type, status
        case contactEmail  = "contact_email"
        case phoneNumber   = "phone_number"
        case createdAt     = "created_at"
    }
}

// MARK: - API Response Wrapper

struct HubsResponse: Decodable {
    let data: [HubDTO]
    let total: Int
    let page: Int
}

// MARK: - DTO → Domain Mapping

extension HubDTO {
    
    /// Converts the network DTO to the domain model.
    /// Returns nil if required fields cannot be parsed.
    func toDomain() -> Hub? {
        guard let uuid = UUID(uuidString: id) else { return nil }
        
        let hubType   = HubType(rawValue: type) ?? .distribution
        let hubStatus = HubStatus(rawValue: status) ?? .inactive
        
        let dateFormatter = ISO8601DateFormatter()
        let date = dateFormatter.date(from: createdAt) ?? Date()
        
        return Hub(
            id: uuid,
            name: name,
            address: address,
            city: city,
            country: country,
            latitude: latitude,
            longitude: longitude,
            capacity: capacity,
            type: hubType,
            status: hubStatus,
            contactEmail: contactEmail,
            phoneNumber: phoneNumber,
            createdAt: date
        )
    }
}
