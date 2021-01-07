import Foundation

struct Location {
    var _id: String
    var name_en: String
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var type: Int
}

extension Location: Identifiable, Equatable, Codable {
    public var id: String {
        self._id
    }
    static func == (l1: Location, l2: Location) -> Bool {
        return l1._id == l2._id && l1.name_en == l2.name_en && l1.latitude == l2.latitude && l1.longitude == l2.longitude && l1.altitude == l2.altitude && l1.type == l2.type
    }
}
