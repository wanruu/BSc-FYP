//
//  CDLocation+CoreDataProperties.swift
//  CU Map
//
//  Created by wanruuu on 5/3/2021.
//
//

import Foundation
import CoreData


extension CDLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDLocation> {
        return NSFetchRequest<CDLocation>(entityName: "CDLocation")
    }

    @NSManaged public var id: String
    @NSManaged public var nameEn: String
    @NSManaged public var nameZh: String
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var altitude: Double
    @NSManaged public var type: Int

    func toLocation() -> Location {
        Location(id: id, nameEn: nameEn, nameZh: nameZh, latitude: latitude, longitude: longitude, altitude: altitude, type: type.toLocationType())
    }
}

extension CDLocation : Identifiable {

}
