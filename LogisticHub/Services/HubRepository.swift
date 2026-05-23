import Foundation
import CoreData

// MARK: - Hub Repository Protocol (Single Responsibility + Interface Segregation)

protocol HubRepositoryProtocol {
    func fetchRemote() async throws -> [Hub]
    func fetchLocal() throws -> [Hub]
    func syncHubs() async throws -> [Hub]
    func searchLocal(query: String) throws -> [Hub]
}

// MARK: - Hub Repository Implementation

/// Coordinates between the network layer and local persistence.
/// Implements the Repository pattern to abstract data sources from ViewModels.
final class HubRepository: HubRepositoryProtocol {
    
    // MARK: - Dependencies
    private let networkService: NetworkServiceProtocol
    private let persistence: PersistenceController
    
    // MARK: - Init (Dependency Injection)
    init(
        networkService: NetworkServiceProtocol = NetworkService(),
        persistence: PersistenceController = .shared
    ) {
        self.networkService = networkService
        self.persistence = persistence
    }
    
    // MARK: - Remote Fetch
    
    func fetchRemote() async throws -> [Hub] {
        // In production, swap MockNetworkService for NetworkService
        let response = try await networkService.fetch(HubsResponse.self, from: .hubs)
        let hubs = response.data.compactMap { $0.toDomain() }
        
        // Persist locally after successful fetch
        persistence.upsertAll(hubs)
        
        return hubs
    }
    
    // MARK: - Local Fetch
    
    func fetchLocal() throws -> [Hub] {
        let context = persistence.container.viewContext
        let request = HubEntity.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            return entities.compactMap { $0.toDomain() }
        } catch {
            throw AppError.persistenceFailed(reason: error.localizedDescription)
        }
    }
    
    // MARK: - Sync (Remote → Local → Return)
    
    /// Fetches fresh data from the API; falls back to local cache on failure.
    func syncHubs() async throws -> [Hub] {
        do {
            return try await fetchRemote()
        } catch {
            // Graceful degradation: use cached data
            let cached = try fetchLocal()
            if cached.isEmpty { throw error }
            return cached
        }
    }
    
    // MARK: - Search
    
    func searchLocal(query: String) throws -> [Hub] {
        let context = persistence.container.viewContext
        let request = HubEntity.fetchRequest()
        
        if !query.isEmpty {
            request.predicate = NSPredicate(
                format: "name CONTAINS[cd] %@ OR city CONTAINS[cd] %@ OR country CONTAINS[cd] %@",
                query, query, query
            )
        }
        
        request.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]
        
        do {
            let entities = try context.fetch(request)
            return entities.compactMap { $0.toDomain() }
        } catch {
            throw AppError.persistenceFailed(reason: error.localizedDescription)
        }
    }
}
