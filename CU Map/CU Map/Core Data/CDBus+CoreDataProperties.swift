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
        var serviceDay: ServiceDay
        switch self.serviceDay {
        case 0: serviceDay = .ordinaryDay
        case 1: serviceDay = .holiday
        case 2: serviceDay = .teachingDay
        default: serviceDay = .ordinaryDay
        }
        let times = serviceHour.split(separator: "-")
        let startTimes = times[0].split(separator: ":")
        let endTimes = times[1].split(separator: ":")
        let startTime = Date(timeIntervalSince1970: TimeInterval(Int(startTimes[0])! * 3600 + Int(startTimes[1])! * 60))
        let endTime = Date(timeIntervalSince1970: TimeInterval(Int(endTimes[0])! * 3600 + Int(endTimes[1])! * 60))
        var stops: [Location] = []
        for stopId in self.stops {
            let stop = locations.first(where: { $0.id == stopId })
            if stop != nil {
                stops.append(stop!)
            }
        }
        return Bus(id: id, line: line, nameEn: nameEn, nameZh: nameZh, serviceHour: ServiceHour(startTime: startTime, endTime: endTime), serviceDay: serviceDay, departTime: departTime, stops: stops)
    }
}

extension CDBus : Identifiable {

}
