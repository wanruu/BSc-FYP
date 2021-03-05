//
//  CDBus+CoreDataProperties.swift
//  CU Map
//
//  Created by wanruuu on 5/3/2021.
//
//

import Foundation
import CoreData


extension CDBus {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CDBus> {
        return NSFetchRequest<CDBus>(entityName: "CDBus")
    }

    @NSManaged public var id: String
    @NSManaged public var line: String
    @NSManaged public var nameEn: String
    @NSManaged public var nameZh: String
    @NSManaged public var serviceHour: String
    @NSManaged public var serviceDay: Int
    @NSManaged public var stops: [String]
    @NSManaged public var departTime: [Int]
    
    func toBus(locations: [Location]) -> Bus {
        Bus(id: id,
            line: line,
            nameEn: nameEn,
            nameZh: nameZh,
            serviceHour: serviceHour.toServiceHour(),
            serviceDay: serviceDay.toServiceDay(),
            departTime: departTime,
            stops: stops.map({
                let stopId = $0
                return locations.first(where: { $0.id == stopId })!
            })
        )
    }
}

extension CDBus : Identifiable {

}
