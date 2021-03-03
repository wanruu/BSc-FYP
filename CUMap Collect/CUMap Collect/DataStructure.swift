import Foundation
import SwiftUI

// Location
struct Location: Identifiable, Equatable {
    var id: String
    var nameEn: String
    var nameZh: String
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var type: LocationType
    
    func toLocResponse() -> LocResponse {
        return LocResponse(_id: id, name_en: nameEn, name_zh: nameZh, latitude: latitude, longitude: longitude, altitude: altitude, type: self.type.toInt())
    }
    
    static func == (location1: Location, location2: Location) -> Bool {
        return location1.id == location2.id && location1.nameEn == location2.nameEn &&
            location1.nameZh == location2.nameZh && location1.latitude == location2.latitude &&
            location1.longitude == location2.longitude && location1.altitude == location2.altitude &&
            location1.type == location2.type
    }
}

enum LocationType {
    case building
    case busStop
    case canteen
    case office
    case sportsArea
    case medical
    case bank
}

extension LocationType {
    func toString() -> String {
        switch self {
        case .building: return "Building"
        case .busStop: return "Bus stop"
        case .canteen: return "Canteen"
        case .office: return "Office"
        case .sportsArea: return "Sports area"
        case .medical: return "Medical"
        case .bank: return "Bank"
        }
    }
    
    func toInt() -> Int {
        switch self {
        case .building: return 0
        case .busStop: return 1
        case .canteen: return 2
        case .office: return 3
        case .sportsArea: return 4
        case .medical: return 5
        case .bank: return 6
        }
    }
    
    func toImage() -> Image {
        var systemName: String
        switch self {
        case .building: systemName = "building.2"
        case .busStop: systemName = "bus"
        case .canteen: systemName = "tuningfork"
        case .office: systemName = "bag"
        case .sportsArea: systemName = "sportscourt"
        case .medical: systemName = "cross"
        case .bank: systemName = "dollarsign.circle"
        }
        return Image(systemName: systemName)
    }
    
    func toUIImage() -> UIImage {
        var systemName: String
        switch self {
        case .building: systemName = "building.2"
        case .busStop: systemName = "bus"
        case .canteen: systemName = "tuningfork"
        case .office: systemName = "bag"
        case .sportsArea: systemName = "sportscourt"
        case .medical: systemName = "cross"
        case .bank: systemName = "dollarsign.circle"
        }
        return UIImage(systemName: systemName)!
    }
}

extension String {
    func toLocationType() -> LocationType {
        switch self {
        case "Building": return .building
        case "Bus stop": return .busStop
        case "Canteen": return .canteen
        case "Office": return .office
        case "Sports area": return .sportsArea
        case "Medical": return .medical
        case "Bank": return .bank
        default: print("fix Data structure: 68"); return .building
        }
    }
}

extension Int {
    func toLocationType() -> LocationType {
        switch self {
        case 0: return .building
        case 1: return .busStop
        case 2: return .canteen
        case 3: return .office
        case 4: return .sportsArea
        case 5: return .medical
        case 6: return .bank
        default: print("fix Data structure: 83"); return .building
        }
    }
    
    func isValidLocationType() -> Bool {
        if self >= 0 && self <= 6 {
            return true
        }
        return false
    }
}


// Bus basic information & bus stop
struct Bus: Identifiable {
    var id: String
    var line: String
    var nameEn: String
    var nameZh: String
    var serviceHour: ServiceHour
    var serviceDay: ServiceDay
    var departTime: [Int]
    var stops: [Location]
    
    func toBusResponse() -> BusResponse {
        var serviceDay: Int
        switch self.serviceDay {
        case .ordinaryDay: serviceDay = 0
        case .holiday: serviceDay = 1
        case .teachingDay: serviceDay = 2
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let serviceHour = formatter.string(from: self.serviceHour.startTime) + "-" + formatter.string(from: self.serviceHour.endTime)
        var stops: [String] = []
        for stop in self.stops {
            stops.append(stop.id)
        }
        return BusResponse(_id: id, line: line, name_en: nameEn, name_zh: nameZh, serviceHour: serviceHour, serviceDay: serviceDay, stops: stops, departTime: departTime)
    }
}

struct ServiceHour {
    var startTime: Date
    var endTime: Date
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: startTime) + " - " + formatter.string(from: endTime)
    }
}

enum ServiceDay {
    case holiday
    case teachingDay
    case ordinaryDay
}

struct Coor3D: Codable, Equatable {
    var latitude: Double
    var longitude: Double
    var altitude: Double
    
    static func == (point1: Coor3D, point2: Coor3D) -> Bool {
        return point1.latitude == point2.latitude && point1.longitude == point2.longitude && point1.altitude == point2.altitude
    }
}

extension String: Identifiable {
    public var id: String {
        self
    }
}

extension Int: Identifiable {
    public var id: Int {
        self
    }
}

struct Route: Identifiable, Equatable {
    var id: String
    var startLoc: Location
    var endLoc: Location
    var points: [Coor3D]
    var dist: Double
    var type: RouteType
    
    func toRouteResponse() -> RouteResponse {
        var type: Int
        switch self.type {
        case .walking: type = 0
        case .bus: type = 1
        }
        return RouteResponse(_id: id, startLoc: startLoc.toLocResponse(), endLoc: endLoc.toLocResponse(), points: points, dist: dist, type: type)
    }
    static func == (route1: Route, route2: Route) -> Bool {
        return route1.id == route2.id
    }
    
}

enum RouteType {
    case walking
    case bus
}



// MARK: - Response
struct LocResponse: Codable {
    var _id: String
    var name_en: String
    var name_zh: String
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var type: Int
    
    func toLocation() -> Location {
        return Location(id: _id, nameEn: name_en, nameZh: name_zh, latitude: latitude, longitude: longitude, altitude: longitude, type: type.toLocationType())
    }
}

struct BusResponse: Codable {
    var _id: String
    var line: String
    var name_en: String
    var name_zh: String
    var serviceHour: String // eg. 07:40-18:40
    var serviceDay: Int // 0: Mon-Sat, 1: Sun&PH, 2: teach
    var stops: [String]
    var departTime: [Int]
    
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
        return Bus(id: _id, line: line, nameEn: name_en, nameZh: name_zh, serviceHour: ServiceHour(startTime: startTime, endTime: endTime), serviceDay: serviceDay, departTime: departTime, stops: stops)
    }
}

struct RouteResponse: Codable {
    var _id: String
    var startLoc: LocResponse
    var endLoc: LocResponse
    var points: [Coor3D]
    var dist: Double
    var type: Int
    
    func toRoute() -> Route {
        var type: RouteType
        switch self.type {
        case 0:
            type = .walking
        case 1:
            type = .bus
        default:
            type = .bus
        }
        return Route(id: _id, startLoc: startLoc.toLocation(), endLoc: endLoc.toLocation(), points: points, dist: dist, type: type)
    }
}


struct DeleteResult: Codable {
    var n: Int
    var ok: Int
    var deletedCount: Int
}

struct PutResult: Codable {
    var n: Int
    var nModified: Int
    var ok: Int
}

struct ProcessResult: Codable {
    var n: Int
    var ok: Int
}
