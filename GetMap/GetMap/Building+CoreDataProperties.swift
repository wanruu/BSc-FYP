//
//  Building+CoreDataProperties.swift
//  GetMap
//
//  Created by wanruuu on 29/10/2020.
//
//

import Foundation
import CoreData


extension Building {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Building> {
        return NSFetchRequest<Building>(entityName: "Building")
    }

    @NSManaged public var name_en: String
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var altitude: Double
}

extension Building : Identifiable {

}
