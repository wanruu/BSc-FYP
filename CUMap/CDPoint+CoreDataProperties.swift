//
//  CDPoint+CoreDataProperties.swift
//  CUMap
//
//  Created by wanruuu on 5/12/2020.
//
//

import Foundation
import CoreData


extension CDPoint {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDPoint> {
        return NSFetchRequest<CDPoint>(entityName: "CDPoint")
    }

    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    @NSManaged public var altitute: Double

}

extension CDPoint : Identifiable {

}
