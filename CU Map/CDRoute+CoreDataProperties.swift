//
//  CDRoute+CoreDataProperties.swift
//  CU Map
//
//  Created by wanruuu on 5/3/2021.
//
//

import Foundation
import CoreData


extension CDRoute {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDRoute> {
        return NSFetchRequest<CDRoute>(entityName: "CDRoute")
    }

    @NSManaged public var id: String
    @NSManaged public var startLoc: CDLocation
    @NSManaged public var endLoc: CDLocation
    @NSManaged public var points: [CDCoor3D]
    @NSManaged public var dist: Double
    @NSManaged public var type: Int
    
    func toRoute() -> Route {
        Route(id: id, startLoc: startLoc.toLocation(), endLoc: endLoc.toLocation(), points: points.map({$0.toCoor3D()}), dist: dist, type: type.toRouteType())
    }
}

extension CDRoute : Identifiable {

}
