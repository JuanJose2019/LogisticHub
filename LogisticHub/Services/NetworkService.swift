import Foundation

// MARK: - Network Service Protocol (Dependency Inversion - SOLID)

protocol NetworkServiceProtocol {
    func fetch<T: Decodable>(_ type: T.Type, from endpoint: APIEndpoint) async throws -> T
}

// MARK: - API Endpoint

enum APIEndpoint {
    case hubs
    case hub(id: String)
    
    var path: String {
        switch self {
        case .hubs:          return "/hubs"
        case .hub(let id):   return "/hubs/\(id)"
        }
    }
}

// MARK: - Network Service Implementation

/// Handles all HTTP requests using URLSession.
/// Supports both async/await and synchronous (DispatchSemaphore) patterns.
final class NetworkService: NetworkServiceProtocol {
    
    // MARK: - Properties
    private let session: URLSession
    private let decoder: JSONDecoder
    private let baseURL: String
    
    // MARK: - Init
    init(
        session: URLSession = .shared,
        baseURL: String = AppConfiguration.baseURL
    ) {
        self.session = session
        self.baseURL = baseURL
        
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }
    
    // MARK: - Async Fetch (Primary - Swift Concurrency)
    
    func fetch<T: Decodable>(_ type: T.Type, from endpoint: APIEndpoint) async throws -> T {
        let request = try buildRequest(for: endpoint)
        
        let (data, response) = try await session.data(for: request)
        try validate(response: response)
        
        do {
            return try decoder.decode(T.self, from: data)
        } catch {
            throw AppError.decodingFailed(reason: error.localizedDescription)
        }
    }
    

    
    // MARK: - Private Helpers
    
    private func buildRequest(for endpoint: APIEndpoint) throws -> URLRequest {
        guard var components = URLComponents(string: baseURL) else {
            throw AppError.invalidURL
        }
        components.path = (components.path + endpoint.path).replacingOccurrences(of: "//", with: "/")
        
        guard let url = components.url else {
            throw AppError.invalidURL
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.timeoutInterval = 30
        return request
    }
    
    @discardableResult
    private func validate(response: URLResponse?) throws -> HTTPURLResponse {
        guard let http = response as? HTTPURLResponse else {
            throw AppError.networkUnavailable
        }
        switch http.statusCode {
        case 200...299: return http
        case 408:       throw AppError.requestTimeout
        default:        throw AppError.serverError(statusCode: http.statusCode)
        }
    }
    
    private func mapURLError(_ error: URLError) -> AppError {
        switch error.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .networkUnavailable
        case .timedOut:
            return .requestTimeout
        default:
            return .unknown(reason: error.localizedDescription)
        }
    }
}
