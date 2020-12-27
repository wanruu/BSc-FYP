import Foundation
import SwiftUI

// MARK: - Location
struct Location: Codable, Identifiable {
    var id: String
    var name_en: String
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var type: Int
}
extension Location: Equatable {
    static func == (l1: Location, l2: Location) -> Bool {
        return l1.id == l2.id
    }
}
// MARK: - A Trajectory
struct Trajectory: Codable, Identifiable {
    var id: String
    var points: [Coor3D]
}
// MARK: - A Route
struct Route: Codable, Identifiable {
    var id: String
    var startId: String
    var endId: String
    var points: [Coor3D]
    var dist: Double
    var type: Int
}
// MARK: - Coor3D
struct Coor3D: Codable {
    var latitude: Double
    var longitude: Double
    var altitude: Double
}
extension Coor3D: Identifiable {
    public var id: String {
        "\(self.latitude)-\(self.longitude)-\(self.altitude)"
    }
}
extension Coor3D {
    static func + (p1: Coor3D, p2: Coor3D) -> Coor3D {
        return Coor3D(latitude: p1.latitude + p2.latitude, longitude: p1.longitude + p2.longitude, altitude: p1.altitude + p2.altitude)
    }
    static func / (point: Coor3D, para: Int) -> Coor3D {
        return Coor3D(latitude: point.latitude / Double(para), longitude: point.longitude / Double(para), altitude: point.altitude / Double(para))
    }
}
extension Coor3D: Equatable {
    static func == (p1: Coor3D, p2: Coor3D) -> Bool {
        return p1.latitude == p2.latitude && p1.longitude == p2.longitude && p1.altitude == p2.altitude
    }
}
// MARK: - LineSegt
struct LineSeg {
    var start: Coor3D
    var end: Coor3D
    var clusterId: Int
}
extension LineSeg: Identifiable {
    public var id: String {
        "\(self.start.id)-\(self.end.id)"
    }
}
// MARK: - Offset, Created to fix the bug of zoom in/out function
struct Offset {
    var x: CGFloat
    var y: CGFloat
}
extension Offset {
    static func * (offset: Offset, para: CGFloat) -> Offset {
        return Offset(x: offset.x * para, y: offset.y * para)
    }
    static func / (offset: Offset, para: CGFloat) -> Offset {
        return Offset(x: offset.x / para, y: offset.y / para)
    }
}
// MARK: - distance function
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

// MARK: - mode
enum NavigationMode {
    case normal // moving will not follow user location
    case undirected
    case directed
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

// MARK: MongoDB result
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

// CU Color
let CUPurple = Color(red: 117/255, green: 15/255, blue: 109/255)
