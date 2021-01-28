import Foundation

struct Route {
    var _id: String
    var startLoc: Location
    var endLoc: Location
    var points: [Coor3D]
    var dist: Double
    var type: Int
}

extension Route: Identifiable, Equatable, Codable {
    public var id: String {
        self._id
    }
    // TODO: may unable to update route
    static func == (r1: Route, r2: Route) -> Bool {
        return r1._id == r2._id && r1.type == r2.type
    }
}
