import Foundation

struct Coor3D {
    var latitude: Double
    var longitude: Double
    var altitude: Double
}

extension Coor3D: Codable, Hashable, Identifiable, Equatable {
    // Identifiable
    public var id: String {
        "\(self.latitude)-\(self.longitude)-\(self.altitude)"
    }
    
    // Equatable
    static func == (p1: Coor3D, p2: Coor3D) -> Bool {
        return p1.latitude == p2.latitude && p1.longitude == p2.longitude && p1.altitude == p2.altitude
    }
    
    static func + (p1: Coor3D, p2: Coor3D) -> Coor3D {
        return Coor3D(latitude: p1.latitude + p2.latitude, longitude: p1.longitude + p2.longitude, altitude: p1.altitude + p2.altitude)
    }
    static func / (point: Coor3D, para: Int) -> Coor3D {
        return Coor3D(latitude: point.latitude / Double(para), longitude: point.longitude / Double(para), altitude: point.altitude / Double(para))
    }
}


func distance(start: Coor3D, end: Coor3D) -> Double {
    let diffX = (start.latitude - end.latitude) * laScale
    let diffY = (start.longitude - end.longitude) * lgScale
    let diffZ = start.altitude - end.altitude
    return pow(diffX * diffX + diffY * diffY + diffZ * diffZ, 0.5)
}

func distance(location: Location, point: Coor3D) -> Double {
    let diffX = (location.latitude - point.latitude) * laScale
    let diffY = (location.longitude - point.longitude) * lgScale
    let diffZ = location.altitude - point.altitude
    return pow(diffX * diffX + diffY * diffY + diffZ * diffZ, 0.5)
}
