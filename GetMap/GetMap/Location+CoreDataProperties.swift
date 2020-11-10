//
//  Location+CoreDataProperties.swift
//  GetMap
//
//  Created by wanruuu on 10/11/2020.
//
//

import Foundation
import CoreData

extension Location {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Location> {
        return NSFetchRequest<Location>(entityName: "Location")
    }

    @NSManaged public var name_en: String
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var altitude: Double
    @NSManaged public var type: Int

}

extension Location : Identifiable {
    
}
