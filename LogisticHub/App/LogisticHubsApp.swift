import SwiftUI

@main
struct LogisticHubsApp: App {
    
    // MARK: - Properties
    private let persistenceController = PersistenceController.shared
    
    // MARK: - Body
    var body: some Scene {
        WindowGroup {
            HubListView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
