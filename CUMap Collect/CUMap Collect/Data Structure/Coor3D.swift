import Foundation

struct Coor3D: Codable, Equatable {
    var latitude: Double
    var longitude: Double
    var altitude: Double
    
    static func == (point1: Coor3D, point2: Coor3D) -> Bool {
        return point1.latitude == point2.latitude && point1.longitude == point2.longitude && point1.altitude == point2.altitude
    }
}
