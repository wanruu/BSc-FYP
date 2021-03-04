//
//  CDCoor3D+CoreDataProperties.swift
//  CU Map
//
//  Created by wanruuu on 5/3/2021.
//
//

import Foundation
import CoreData


extension CDCoor3D {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDCoor3D> {
        return NSFetchRequest<CDCoor3D>(entityName: "CDCoor3D")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var altitude: Double
    
    func toCoor3D() -> Coor3D {
        Coor3D(latitude: latitude, longitude: longitude, altitude: altitude)
    }
}

extension CDCoor3D : Identifiable {

}
