import Foundation

struct Route: Identifiable, Equatable {
    var id: String
    var startLoc: Location
    var endLoc: Location
    var points: [Coor3D]
    var dist: Double
    var type: RouteType
    
    func toRouteResponse() -> RouteResponse {
        RouteResponse(_id: id, startLoc: startLoc.toLocResponse(), endLoc: endLoc.toLocResponse(), points: points, dist: dist, type: self.type.toInt())
    }
    static func == (route1: Route, route2: Route) -> Bool {
        return route1.id == route2.id
    }
}

struct RouteByBus {
    var id = UUID()
    var bus: Bus
    var startLoc: Location
    var endLoc: Location
    var points: [Coor3D]
    var dist: Double
    var type = RouteType.byBus
}

enum RouteType {
    case onFoot
    case byBus
}

extension RouteType {
    func toInt() -> Int {
        switch self {
        case .onFoot: return 0
        case .byBus: return 1
        }
    }
    
    func toString() -> String {
        switch self {
        case .onFoot: return "on foot"
        case .byBus: return "by bus"
        }
    }
}

extension Int {
    func toRouteType() -> RouteType {
        switch self {
        case 0: return .onFoot
        case 1: return .byBus
        default: return .onFoot
        }
    }
    
    func isValidRouteType() -> Bool {
        if self >= 0 && self <= 1 {
            return true
        }
        return false
    }
}

extension String {
    func toRouteType() -> RouteType {
        switch self {
        case "on foot": return .onFoot
        case "by bus": return .byBus
        default: return .onFoot
        }
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
        Route(id: _id, startLoc: startLoc.toLocation(), endLoc: endLoc.toLocation(), points: points, dist: dist, type: type.toRouteType())
    }
}

