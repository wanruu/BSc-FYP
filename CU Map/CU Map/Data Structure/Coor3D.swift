import Foundation

struct Coor3D: Codable, Equatable {
    var latitude: Double
    var longitude: Double
    var altitude: Double
    
    static func == (point1: Coor3D, point2: Coor3D) -> Bool {
        point1.latitude == point2.latitude && point1.longitude == point2.longitude && point1.altitude == point2.altitude
    }
}

func distance (from: Coor3D, to: Coor3D) -> Double {
    pow((from.latitude - to.latitude) * LAT_SCALE * (from.latitude - to.latitude) * LAT_SCALE +
        (from.longitude - to.longitude) * LNG_SCALE * (from.longitude - to.longitude) * LNG_SCALE +
        (from.altitude - to.altitude) * (from.altitude - to.altitude), 0.5)
}
