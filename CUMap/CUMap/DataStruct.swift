//
//  DataStruct.swift
//  CUMap
//
//  Created by wanruuu on 5/12/2020.
//

import Foundation
import SwiftUI

// MARK: - Location
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
        return l1._id == l2._id
    }
}

// MARK: - A Unit Route
struct Route {
    var _id: String
    var startLoc: Location
    var endLoc: Location
    var points: [Coor3D]
    var dist: Double
    var type: [Int]
}
extension Route: Identifiable, Equatable, Codable {
    public var id: String {
        self._id
    }
    static func == (r1: Route, r2: Route) -> Bool {
        return r1._id == r2._id
    }
}

// MARK: - A plan
struct Plan {
    var startLoc: Location
    var endLoc: Location
    var routes: [Route]
    var dist: Double // meters
    var time: Double // seconds
    var ascent: Double // meters
    var type: Int
}
extension Plan: Identifiable {
    public var id: String {
        "\(self.startLoc._id)\(self.endLoc._id)\(self.dist)\(self.time)\(self.type)"
    }
}

// MARK: - Version
struct Version: Codable {
    var database: String
    var version: String
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
extension Offset: Equatable {
    static func == (o1: Offset, o2: Offset) -> Bool {
        return o1.x == o2.x && o1.y == o2.y
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

func distance(p1: CGPoint, p2: CGPoint) -> CGFloat {
    let diffX = p1.x - p2.x
    let diffY = p1.y - p2.y
    return pow(diffX * diffX + diffY * diffY, 0.5)
}

// MARK: View Extension
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


struct RoundedCorners: View {
    var color: Color = .blue
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0
 
    var body: some View {
        GeometryReader { geometry in
            Path { path in
 
                let w = geometry.size.width
                let h = geometry.size.height
 
                // Make sure we do not exceed the size of the rectangle
                let tr = min(min(self.tr, h/2), w/2)
                let tl = min(min(self.tl, h/2), w/2)
                let bl = min(min(self.bl, h/2), w/2)
                let br = min(min(self.br, h/2), w/2)
 
                path.move(to: CGPoint(x: w / 2.0, y: 0))
                path.addLine(to: CGPoint(x: w - tr, y: 0))
                path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
                path.addLine(to: CGPoint(x: w, y: h - br))
                path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
                path.addLine(to: CGPoint(x: bl, y: h))
                path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
                path.addLine(to: CGPoint(x: 0, y: tl))
                path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
            }
            .fill(self.color)
        }
    }
}
