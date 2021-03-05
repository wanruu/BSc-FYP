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
    @NSManaged public var startLoc: String
    @NSManaged public var endLoc: String
    @NSManaged public var points: [CDCoor3D]
    @NSManaged public var dist: Double
    @NSManaged public var type: Int
    
    func toRoute(locations: [Location]) -> Route {
        Route(id: id,
              startLoc: locations.first(where: { $0.id == startLoc })!,
              endLoc: locations.first(where: { $0.id == endLoc })!,
              points: points.map({ $0.toCoor3D() }),
              dist: dist,
              type: type.toRouteType()
        )
    }
}

extension CDRoute : Identifiable {

}
