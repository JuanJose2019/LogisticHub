import CoreData

// MARK: - Persistence Controller

/// Manages the Core Data stack following the singleton pattern.
/// Responsible for setting up the persistent container and providing save/fetch operations.
final class PersistenceController {
    
    // MARK: - Singleton
    static let shared = PersistenceController()
    
    // MARK: - Preview Instance
    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let context = controller.container.viewContext
        
        // Seed preview data
        MockHubFactory.makeAll().forEach { hub in
            let entity = HubEntity(context: context)
            entity.populate(from: hub)
        }
        
        try? context.save()
        return controller
    }()
    
    // MARK: - Container
    let container: NSPersistentContainer
    
    // MARK: - Init
    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "LogisticHubs")
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error {
                // In production, handle this gracefully (e.g., delete and recreate store)
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Save
    
    /// Saves the view context if it has unsaved changes.
    func save() {
        let context = container.viewContext
        guard context.hasChanges else { return }
        
        do {
            try context.save()
        } catch {
            print("⚠️ Core Data save error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Upsert
    
    /// Inserts or updates a Hub entity from the domain model.
    func upsert(hub: Hub) {
        let context = container.viewContext
        let request = HubEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", hub.id as CVarArg)
        
        let entity: HubEntity
        if let existing = try? context.fetch(request).first {
            entity = existing
        } else {
            entity = HubEntity(context: context)
        }
        
        entity.populate(from: hub)
        save()
    }
    
    /// Batch upserts an array of hubs efficiently on a background thread.
    func upsertAll(_ hubs: [Hub]) {
        container.performBackgroundTask { context in
            context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            
            for hub in hubs {
                let request = HubEntity.fetchRequest()
                request.predicate = NSPredicate(format: "id == %@", hub.id as CVarArg)
                
                let entity: HubEntity
                if let existing = try? context.fetch(request).first {
                    entity = existing
                } else {
                    entity = HubEntity(context: context)
                }
                
                entity.populate(from: hub)
            }
            
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    print("⚠️ Background context save error: \(error.localizedDescription)")
                }
            }
        }
    }
    
    // MARK: - Delete
    
    func delete(hub: Hub) {
        let context = container.viewContext
        let request = HubEntity.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", hub.id as CVarArg)
        
        guard let entity = try? context.fetch(request).first else { return }
        context.delete(entity)
        save()
    }
}
