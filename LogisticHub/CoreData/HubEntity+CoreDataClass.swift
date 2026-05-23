import CoreData
import Foundation

// MARK: - HubEntity Core Data Extension

/// Extension on the auto-generated NSManagedObject subclass.
/// Provides mapping between Core Data entity and domain model.
extension HubEntity {
    
    // MARK: - Fetch Request Factory
    
    @nonobjc class func fetchRequest() -> NSFetchRequest<HubEntity> {
        NSFetchRequest<HubEntity>(entityName: "HubEntity")
    }
    
    // MARK: - Populate from Domain
    
    func populate(from hub: Hub) {
        self.id          = hub.id
        self.name        = hub.name
        self.address     = hub.address
        self.city        = hub.city
        self.country     = hub.country
        self.latitude    = hub.latitude
        self.longitude   = hub.longitude
        self.capacity    = Int32(hub.capacity)
        self.type        = hub.type.rawValue
        self.status      = hub.status.rawValue
        self.contactEmail = hub.contactEmail
        self.phoneNumber  = hub.phoneNumber
        self.createdAt    = hub.createdAt
    }
    
    // MARK: - Convert to Domain
    
    func toDomain() -> Hub? {
        guard
            let id    = self.id,
            let name  = self.name,
            let addr  = self.address,
            let city  = self.city,
            let cntry = self.country,
            let cEmail = self.contactEmail,
            let phone  = self.phoneNumber,
            let date   = self.createdAt,
            let typeRaw   = self.type,
            let statusRaw = self.status
        else { return nil }
        
        return Hub(
            id: id,
            name: name,
            address: addr,
            city: city,
            country: cntry,
            latitude: self.latitude,
            longitude: self.longitude,
            capacity: Int(self.capacity),
            type: HubType(rawValue: typeRaw) ?? .distribution,
            status: HubStatus(rawValue: statusRaw) ?? .inactive,
            contactEmail: cEmail,
            phoneNumber: phone,
            createdAt: date
        )
    }
}

// MARK: - HubEntity Core Data Attributes
// NOTE: The actual @NSManaged properties are declared in the .xcdatamodeld file.
// The attributes on the entity should be:
//   id           UUID
//   name         String
//   address      String
//   city         String
//   country      String
//   latitude     Double
//   longitude    Double
//   capacity     Integer 32
//   type         String
//   status       String
//   contactEmail String
//   phoneNumber  String
//   createdAt    Date
//
// Class: HubEntity, Module: LogisticHubs, Codegen: Manual/None

@objc(HubEntity)
public class HubEntity: NSManagedObject {
    @NSManaged public var id: UUID?
    @NSManaged public var name: String?
    @NSManaged public var address: String?
    @NSManaged public var city: String?
    @NSManaged public var country: String?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var capacity: Int32
    @NSManaged public var type: String?
    @NSManaged public var status: String?
    @NSManaged public var contactEmail: String?
    @NSManaged public var phoneNumber: String?
    @NSManaged public var createdAt: Date?
}
