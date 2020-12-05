//
//  CDPath+CoreDataProperties.swift
//  CUMap
//
//  Created by wanruuu on 5/12/2020.
//
//

import Foundation
import CoreData


extension CDPath {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDPath> {
        return NSFetchRequest<CDPath>(entityName: "CDPath")
    }

    @NSManaged public var start: CDLocation
    @NSManaged public var end: CDLocation
    @NSManaged public var points: [CDPoint]
    @NSManaged public var dist: Double
    @NSManaged public var type: Int

}

extension CDPath : Identifiable {

}
