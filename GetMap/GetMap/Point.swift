/* MARK: Data Structure (Point) */

import Foundation

struct Point {
    var x: Double
    var y: Double
    var z: Double
}

extension Point {
    static func + (p1: Point, p2: Point) -> Point {
        return Point(x: p1.x + p2.x, y: p1.y + p2.y, z: p1.z + p2.z)
    }
    static func - (p1: Point, p2: Point) -> Point {
        return Point(x: p1.x - p2.x, y: p1.y - p2.y, z: p1.z - p2.z)
    }
    static func * (p1: Point, p2: Point) -> Double {
        return p1.x * p2.x + p1.y * p2.y + p1.z * p2.z
    }
    static func * (para: Double, p: Point) -> Point {
        return Point(x: p.x * para, y: p.y * para, z: p.z * para)
    }
    static func * (p: Point, para: Double)  -> Point {
        return para * p
    }
    static func / (p: Point, para: Double) -> Point {
        return Point(x: p.x / para, y: p.y / para, z: p.z / para)
    }
}
