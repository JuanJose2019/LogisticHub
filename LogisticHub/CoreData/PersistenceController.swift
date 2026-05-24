import CoreData

// MARK: - Persistence Controller

/// Manages the Core Data stack following the singleton pattern.
/// Configured programmatically (no .xcdatamodeld visual file required).
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
    
    // MARK: - Programmatic Data Model
    private static func createModel() -> NSManagedObjectModel {
        let model = NSManagedObjectModel()
        
        let entity = NSEntityDescription()
        entity.name = "HubEntity"
        entity.managedObjectClassName = NSStringFromClass(HubEntity.self)
        
        // Atributos
        let idAttr = NSAttributeDescription(); idAttr.name = "id"; idAttr.attributeType = .UUIDAttributeType; idAttr.isOptional = true
        let nameAttr = NSAttributeDescription(); nameAttr.name = "name"; nameAttr.attributeType = .stringAttributeType; nameAttr.isOptional = true
        let addressAttr = NSAttributeDescription(); addressAttr.name = "address"; addressAttr.attributeType = .stringAttributeType; addressAttr.isOptional = true
        let cityAttr = NSAttributeDescription(); cityAttr.name = "city"; cityAttr.attributeType = .stringAttributeType; cityAttr.isOptional = true
        let countryAttr = NSAttributeDescription(); countryAttr.name = "country"; countryAttr.attributeType = .stringAttributeType; countryAttr.isOptional = true
        let typeAttr = NSAttributeDescription(); typeAttr.name = "type"; typeAttr.attributeType = .stringAttributeType; typeAttr.isOptional = true
        let statusAttr = NSAttributeDescription(); statusAttr.name = "status"; statusAttr.attributeType = .stringAttributeType; statusAttr.isOptional = true
        let emailAttr = NSAttributeDescription(); emailAttr.name = "contactEmail"; emailAttr.attributeType = .stringAttributeType; emailAttr.isOptional = true
        let phoneAttr = NSAttributeDescription(); phoneAttr.name = "phoneNumber"; phoneAttr.attributeType = .stringAttributeType; phoneAttr.isOptional = true
        let createdAttr = NSAttributeDescription(); createdAttr.name = "createdAt"; createdAttr.attributeType = .dateAttributeType; createdAttr.isOptional = true
        
        // Numéricos (No opcionales en nuestra clase)
        let latAttr = NSAttributeDescription(); latAttr.name = "latitude"; latAttr.attributeType = .doubleAttributeType; latAttr.isOptional = false; latAttr.defaultValue = 0.0
        let lonAttr = NSAttributeDescription(); lonAttr.name = "longitude"; lonAttr.attributeType = .doubleAttributeType; lonAttr.isOptional = false; lonAttr.defaultValue = 0.0
        let capAttr = NSAttributeDescription(); capAttr.name = "capacity"; capAttr.attributeType = .integer32AttributeType; capAttr.isOptional = false; capAttr.defaultValue = 0
        
        entity.properties = [
            idAttr, nameAttr, addressAttr, cityAttr, countryAttr,
            latAttr, lonAttr, capAttr, typeAttr, statusAttr,
            emailAttr, phoneAttr, createdAttr
        ]
        
        model.entities = [entity]
        return model
    }
    
    // MARK: - Init
    init(inMemory: Bool = false) {
        // Inicializamos usando el modelo programático!
        let model = Self.createModel()
        container = NSPersistentContainer(name: "LogisticHubs", managedObjectModel: model)
        
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error.localizedDescription)")
            }
        }
        
        container.viewContext.automaticallyMergesChangesFromParent = true
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }
    
    // MARK: - Save
    func save() {
        let context = container.viewContext
        guard context.hasChanges else { return }
        do { try context.save() } catch { print("⚠️ Core Data save error: \(error.localizedDescription)") }
    }
    
    // MARK: - Upsert
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
            if context.hasChanges { try? context.save() }
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
