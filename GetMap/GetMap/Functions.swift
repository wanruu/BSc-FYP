//
//  Functions.swift
//  GetMap
//
//  Created by wanruuu on 31/10/2020.
//

import Foundation
import CoreLocation

/* three types of distance result */
struct Distance {
    var perpendicular: Double
    var parallel: Double
    var angle: Double
}
struct Point {
    var x: Double
    var y: Double
    var z: Double
}
struct Vector {
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
    static func * (left: Double, right: Point) -> Point {
        return Point(x: right.x * left, y: right.y * left, z: right.z * left)
    }
}

/* trajectory partitioning */
func MDLPar(path: [CLLocation], startIndex: Int, endIndex: Int) -> Double {
    /* only two cp in this trajectory */
    /* distance between two charateristic points */
    var angleSum = 0.0
    var perpSum = 0.0
    let x1: Double = path[startIndex].coordinate.latitude
    let y1: Double = path[startIndex].coordinate.longitude
    let z1: Double = path[startIndex].altitude
    let x2: Double = path[endIndex].coordinate.latitude
    let y2: Double = path[endIndex].coordinate.longitude
    let z2: Double = path[endIndex].altitude

    for index in startIndex...(endIndex - 1) {
        let dist = computDistance(locations: [path[startIndex], path[endIndex], path[index], path[index+1]])
        /* perpendicular distance */
        perpSum += dist.perpendicular
        /* angle distance */
        angleSum += dist.angle
    }
    let LH: Double = log2(pow((x1-x2)*(x1-x2)*111000 + (y1-y2)*(y1-y2)*85390 + (z1-z2)*(z1-z2), 0.5))
    let LH_D = log2(angleSum) + log2(perpSum)
    return LH + LH_D
}

func MDLNotPar(path: [CLLocation], startIndex: Int, endIndex: Int) -> Double {
    var LH: Double = 0
    // LH_D = 0 under this situation
    for index in startIndex...(endIndex - 1) {
        let diffX: Double = (path[index].coordinate.latitude - path[index+1].coordinate.latitude) * 111000
        let diffY: Double = (path[index].coordinate.longitude - path[index+1].coordinate.longitude) * 85390
        let diffZ: Double = path[index].altitude - path[index+1].altitude
        LH += log2( pow( diffX*diffX+diffY*diffY+diffZ*diffZ, 0.5 ) )
    }
    return LH
}

/* calculate distance of 2 points */
func length(start: Point, end: Point) -> Double {
    return pow(
        (start.x - end.x) * (start.x - end.x) +
        (start.y - end.y) * (start.y - end.y) +
        (start.z - end.z) * (start.z - end.z), 0.5)
}

/* distance function: calculate distance between p1p2 and p3p4 */
func computDistance(locations: [CLLocation]) -> Distance {
    /* assume p1p2 > p3p4 */
    /* ensure input parameters are valid */
    if(locations.count != 4) {
        fatalError("Parameter error in function distance.")
    }
    /* change CLLocation to coordinate */
    var points : [Point] = []
    points.append(Point(x: 0, y: 0, z: 0)) // regard points[0] as origin
    for index in 1...3 {
        let point = Point(
            x: (locations[index].coordinate.latitude - locations[0].coordinate.latitude) * 111000,
            y: (locations[index].coordinate.longitude - locations[0].coordinate.longitude) * 85390,
            z: locations[index].altitude - locations[0].altitude)
        points.append(point)
    }
    /* calculate something for later computing */
    let length1 = length(start: points[0], end: points[1]) // length of p1p2
    let length2 = length(start: points[2], end: points[3]) // length of p3p4
    let proj_p3 = ((points[2] * points[1]) / length1) * points[1] // projection point of p3 onto p1p2
    let proj_p4 = ((points[3] * points[1]) / length1) * points[1] // projection point of p4 onto p1p2
    let theta = acos(points[1] * (points[3] - points[2]) / length1 / length2)
    /* perpendicular distance */
    let l1 = length(start: proj_p3, end: points[2])
    let l2 = length(start: proj_p4, end: points[3])
    let perp = (l1 * l1 + l2 * l2) / (l1 + l2)
    /* parallel distance */
    /* angle distance: no direction */
    let angle = length1 * sin(theta)
    return Distance(perpendicular: perp, parallel: 0, angle: angle)
}
