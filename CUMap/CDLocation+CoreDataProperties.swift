//
//  CDLocation+CoreDataProperties.swift
//  CUMap
//
//  Created by wanruuu on 5/12/2020.
//
//

import Foundation
import CoreData


extension CDLocation {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDLocation> {
        return NSFetchRequest<CDLocation>(entityName: "CDLocation")
    }

    @NSManaged public var altitude: Double
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var name_en: String
    @NSManaged public var type: Int

}

extension CDLocation : Identifiable {

}
