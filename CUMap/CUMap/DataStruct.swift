//
//  DataStruct.swift
//  CUMap
//
//  Created by wanruuu on 5/12/2020.
//

import Foundation
import SwiftUI

/* MARK: - Location */
struct Location: Codable {
    var name_en: String
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var type: Int
}
extension Location: Identifiable {
    public var id: String {
        self.name_en
    }
}
extension Location: Equatable {
    static func == (l1: Location, l2: Location) -> Bool {
        return l1.name_en == l2.name_en && l1.type == l2.type
    }
}

// MARK: - path between
struct TmpLocation: Codable {
    var name_en: String
    var type: Int
}
struct PathBtwn: Codable {
    var start: TmpLocation
    var end: TmpLocation
    var path: [Coor3D]
    var dist: Double
    var type: Int
}

extension PathBtwn: Identifiable {
    public var id: String {
        self.start.name_en + String(self.start.type) + self.end.name_en + String(self.end.type)
    }
}
// MARK: - Version
struct Version: Codable {
    var database: String
    var version: String
}

/* MARK: - Coor3D */
struct Coor3D: Codable {
    var latitude: Double
    var longitude: Double
    var altitude: Double
}
extension Coor3D: Identifiable {
    public var id: String {
        "\(self.latitude)\(self.longitude)"
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

/* MARK: - Offset, Created to fix the bug of zoom in/out function */
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
/* MARK: - distance function */
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


