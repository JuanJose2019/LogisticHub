import Foundation

// MARK: - Mock Network Service

/// Simulates API responses using local JSON.
/// Replace with NetworkService in production builds.
final class MockNetworkService: NetworkServiceProtocol {
    
    func fetch<T: Decodable>(_ type: T.Type, from endpoint: APIEndpoint) async throws -> T {
        // Simulate network delay
        try await Task.sleep(nanoseconds: 800_000_000) // 0.8s
        return try decodeFromMock(type)
    }
    

    
    private func decodeFromMock<T: Decodable>(_ type: T.Type) throws -> T {
        let json = MockJSONProvider.hubsJSON
        guard let data = json.data(using: .utf8) else {
            throw AppError.decodingFailed(reason: "Cannot encode mock JSON")
        }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw AppError.decodingFailed(reason: error.localizedDescription)
        }
    }
}

// MARK: - Mock JSON Provider

enum MockJSONProvider {
    
    static let hubsJSON = """
    {
      "total": 6,
      "page": 1,
      "data": [
        {
          "id": "A1B2C3D4-E5F6-7890-ABCD-EF1234567890",
          "name": "Centro Logístico Norte",
          "address": "Calle Industrial 45",
          "city": "San Salvador",
          "country": "El Salvador",
          "latitude": 13.6929,
          "longitude": -89.2182,
          "capacity": 15000,
          "type": "distribution",
          "status": "active",
          "contact_email": "norte@logistica.sv",
          "phone_number": "+503 2222-3333",
          "created_at": "2023-01-15T08:00:00Z"
        },
        {
          "id": "B2C3D4E5-F6A7-8901-BCDE-F12345678901",
          "name": "Hub Almacenamiento Sur",
          "address": "Av. Comercial 120",
          "city": "Santa Ana",
          "country": "El Salvador",
          "latitude": 13.9944,
          "longitude": -89.5597,
          "capacity": 8000,
          "type": "storage",
          "status": "active",
          "contact_email": "sur@logistica.sv",
          "phone_number": "+503 2444-5555",
          "created_at": "2023-03-10T09:30:00Z"
        },
        {
          "id": "C3D4E5F6-A7B8-9012-CDEF-123456789012",
          "name": "Cross-Docking Oriente",
          "address": "Blvd. Logístico 88",
          "city": "San Miguel",
          "country": "El Salvador",
          "latitude": 13.4833,
          "longitude": -88.1833,
          "capacity": 5000,
          "type": "crossdocking",
          "status": "maintenance",
          "contact_email": "oriente@logistica.sv",
          "phone_number": "+503 2666-7777",
          "created_at": "2023-06-22T11:00:00Z"
        },
        {
          "id": "D4E5F6A7-B8C9-0123-DEF0-234567890123",
          "name": "Fulfillment Center Occidente",
          "address": "Parque Industrial Zona 4",
          "city": "Sonsonate",
          "country": "El Salvador",
          "latitude": 13.7189,
          "longitude": -89.7242,
          "capacity": 12000,
          "type": "fulfillment",
          "status": "active",
          "contact_email": "occidente@logistica.sv",
          "phone_number": "+503 2888-9999",
          "created_at": "2023-09-01T10:00:00Z"
        },
        {
          "id": "E5F6A7B8-C9D0-1234-EF01-345678901234",
          "name": "Hub Regional Guatemala",
          "address": "Zona 12 Industrial",
          "city": "Ciudad de Guatemala",
          "country": "Guatemala",
          "latitude": 14.6349,
          "longitude": -90.5069,
          "capacity": 20000,
          "type": "distribution",
          "status": "active",
          "contact_email": "guatemala@logistica.gt",
          "phone_number": "+502 2222-1111",
          "created_at": "2022-11-05T08:00:00Z"
        },
        {
          "id": "F6A7B8C9-D0E1-2345-F012-456789012345",
          "name": "Bodega Inactiva Central",
          "address": "Colonia Industrial 7",
          "city": "Tegucigalpa",
          "country": "Honduras",
          "latitude": 14.0723,
          "longitude": -87.2023,
          "capacity": 3500,
          "type": "storage",
          "status": "inactive",
          "contact_email": "honduras@logistica.hn",
          "phone_number": "+504 2222-0000",
          "created_at": "2021-08-14T07:00:00Z"
        }
      ]
    }
    """
}

// MARK: - Mock Hub Factory (for Previews)

enum MockHubFactory {
    
    static func makeAll() -> [Hub] {
        guard let data = MockJSONProvider.hubsJSON.data(using: .utf8) else { return [] }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let response = try? decoder.decode(HubsResponse.self, from: data)
        return response?.data.compactMap { $0.toDomain() } ?? []
    }
    
    static func make() -> Hub {
        makeAll().first ?? Hub(
            id: UUID(),
            name: "Hub de Prueba",
            address: "Calle Falsa 123",
            city: "San Salvador",
            country: "El Salvador",
            latitude: 13.6929,
            longitude: -89.2182,
            capacity: 10000,
            type: .distribution,
            status: .active,
            contactEmail: "test@test.com",
            phoneNumber: "+503 0000-0000",
            createdAt: Date()
        )
    }
}
