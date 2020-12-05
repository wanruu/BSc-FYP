//
//  CDVersion+CoreDataProperties.swift
//  CUMap
//
//  Created by wanruuu on 5/12/2020.
//
//

import Foundation
import CoreData


extension CDVersion {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDVersion> {
        return NSFetchRequest<CDVersion>(entityName: "CDVersion")
    }

    @NSManaged public var database: String
    @NSManaged public var version: String

}

extension CDVersion : Identifiable {

}
