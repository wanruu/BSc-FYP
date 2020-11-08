//
//  Point.swift
//  GetMap
//
//  Created by wanruuu on 9/11/2020.
//

import Foundation

struct Point {
    var x: Double
    var y: Double
    var z: Double
}
extension Point {
    static func + (left: Point, right: Point) -> Point {
        return Point(x: left.x + right.x, y: left.y + right.y, z: left.z + right.z)
    }
    static func - (left: Point, right: Point) -> Point {
        return Point(x: left.x - right.x, y: left.y - right.y, z: left.z - right.z)
    }
    static func * (left: Point, right: Point) -> Double {
        return left.x * right.x + left.y * right.y + left.z * right.z
    }
    static func * (para: Double, p: Point) -> Point {
        return Point(x: p.x * para, y: p.y * para, z: p.z * para)
    }
    static func * (p: Point, para: Double)  -> Point {
        return Point(x: p.x * para, y: p.y * para, z: p.z * para)
    }
    static func / (left: Point, right: Double) -> Point {
        return Point(x: left.x / right, y: left.y / right, z: left.z / right)
    }
}
