//
//  Path+CoreDataProperties.swift
//  GetMap
//
//  Created by wanruuu on 5/11/2020.
//
//

import Foundation
import CoreData


extension Path {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Path> {
        return NSFetchRequest<Path>(entityName: "Path")
    }

    @NSManaged public var locations: NSObject?

}

extension Path : Identifiable {

}
