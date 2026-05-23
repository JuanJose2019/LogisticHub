import Foundation
import Combine

// MARK: - Hub List ViewModel

/// ViewModel for the hub list screen.
/// Follows MVVM: owns presentation state, delegates data operations to the repository.
@MainActor
final class HubListViewModel: ObservableObject {
    
    // MARK: - Published State
    @Published private(set) var hubs: [Hub] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var error: AppError?
    @Published var searchQuery: String = ""
    @Published var selectedFilter: HubStatus? = nil
    
    // MARK: - Computed
    var filteredHubs: [Hub] {
        var result = hubs
        
        if !searchQuery.isEmpty {
            result = result.filter {
                $0.name.localizedCaseInsensitiveContains(searchQuery) ||
                $0.city.localizedCaseInsensitiveContains(searchQuery) ||
                $0.country.localizedCaseInsensitiveContains(searchQuery)
            }
        }
        
        if let filter = selectedFilter {
            result = result.filter { $0.status == filter }
        }
        
        return result
    }
    
    var isEmpty: Bool { filteredHubs.isEmpty && !isLoading }
    var hasError: Bool { error != nil }
    
    // MARK: - Dependencies
    private let repository: HubRepositoryProtocol
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Init
    init(repository: HubRepositoryProtocol = HubRepository(
        networkService: MockNetworkService() // swap to NetworkService() in production
    )) {
        self.repository = repository
        loadCachedHubs()
    }
    
    // MARK: - Intent: Load
    
    func loadHubs() {
        guard !isLoading else { return }
        isLoading = true
        error = nil
        
        Task {
            do {
                let fetched = try await repository.syncHubs()
                hubs = fetched.sorted { $0.name < $1.name }
            } catch let appError as AppError {
                self.error = appError
            } catch {
                self.error = .unknown(reason: error.localizedDescription)
            }
            isLoading = false
        }
    }
    
    // MARK: - Intent: Refresh
    
    func refresh() {
        hubs = []
        loadHubs()
    }
    
    // MARK: - Intent: Dismiss Error
    
    func dismissError() {
        error = nil
    }
    
    // MARK: - Private
    
    /// Load from Core Data immediately for instant UI on app launch.
    private func loadCachedHubs() {
        do {
            let cached = try repository.fetchLocal()
            if !cached.isEmpty {
                hubs = cached.sorted { $0.name < $1.name }
            }
        } catch {
            print("⚠️ Cache load failed: \(error.localizedDescription)")
        }
    }
}
