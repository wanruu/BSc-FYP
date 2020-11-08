//
//  PathUnit+CoreDataProperties.swift
//  GetMap
//
//  Created by wanruuu on 29/10/2020.
//
//

import Foundation
import CoreData

extension PathUnit {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PathUnit> {
        return NSFetchRequest<PathUnit>(entityName: "PathUnit")
    }

    @NSManaged public var start_point: CLLocation
    @NSManaged public var end_point: CLLocation
    @NSManaged public var clusterId: Int

}

extension PathUnit : Identifiable {

}
