/* MARK: Representative Trajectory Generation */

import Foundation
import CoreLocation

let r = 0.3

/* convert locations to points */
func locationsToPoints(pathUnits: [PathUnit]) -> [Point] {
    var points: [Point] = []
    // assume pathUnits[0].start_point as origin point
    for pathUnit in pathUnits {
        points.append(Point(
            x: (pathUnit.start_point.coordinate.latitude - pathUnits[0].start_point.coordinate.latitude) * laScale,
            y: (pathUnit.start_point.coordinate.longitude - pathUnits[0].start_point.coordinate.longitude) * lgScale,
            z: pathUnit.start_point.altitude - pathUnits[0].start_point.altitude))
        points.append(Point(
            x: (pathUnit.end_point.coordinate.latitude - pathUnits[0].start_point.coordinate.latitude) * laScale,
            y: (pathUnit.end_point.coordinate.longitude - pathUnits[0].start_point.coordinate.longitude) * lgScale,
            z: pathUnit.end_point.altitude - pathUnits[0].start_point.altitude))
    }
    return points
}

/* convert points to vectors: [v1, v2, ..., vn] */
func pointsToVectors(points: [Point]) -> [Point] {
    var vectors: [Point] = []
    var index = 0
    while(index <= points.count - 2) {
        vectors.append(points[index+1] - points[index])
        index += 2
    }
    return vectors
}

/* compute average direction vector */
func computeAverVector(vectors: [Point]) -> Point {
    var averVector = Point(x: 0, y: 0, z: 0)
    /* find axis in which vector change most */
    var x = 0.0
    var y = 0.0
    for vector in vectors {
        x += abs(vector.x)
        y += abs(vector.y)
    }
    if(x > y) {
        for index in 0..<vectors.count {
            if(vectors[index].x * vectors[0].x < 0) {
                averVector = averVector - vectors[index]
            } else {
                averVector = averVector + vectors[index]
            }
        }
    } else {
        for index in 0..<vectors.count {
            if(vectors[index].y * vectors[0].y < 0) {
                averVector = averVector - vectors[index]
            } else {
                averVector = averVector + vectors[index]
            }
        }
    }
    averVector = averVector / Double(vectors.count)
    return averVector
}
/* rotate */
func rotateByZ(point: Point, angle: Double) -> Point { // clockwise
    let newPoint = Point(
        x: point.x * cos(angle) + point.y * sin(angle),
        y: point.y * cos(angle) - point.x * sin(angle),
        z: point.z)
    return newPoint
}
func rotateByY(point: Point, angle: Double) -> Point { // anti-clockwise
    let newPoint = Point(
        x: point.x * cos(angle) + point.z * sin(angle),
        y: point.y,
        z: point.z * cos(angle) - point.x * sin(angle))
    return newPoint
}
func rotate(point: Point, alpha: Double, beta: Double) -> Point {
    let p1 = rotateByZ(point: point, angle: alpha)
    let p2 = rotateByY(point: p1, angle: beta)
    return p2
}
func unrotate(point: Point, alpha: Double, beta: Double) -> Point {
    let p1 = rotateByY(point: point, angle: -beta)
    let p2 = rotateByZ(point: p1, angle: -alpha)
    return p2
}
func generateRepresent(pathUnits: [PathUnit]) -> [CLLocation] {
    var representLocations: [CLLocation] = []
    if(pathUnits.count == 0) {
        return representLocations
    }
    /* convert pathUnits to points: [p1, p2, ..., p2n-1, p2n] where p1, p2 are start and end point of pathUnit[0] */
    var points = locationsToPoints(pathUnits: pathUnits)
    
    /* convert pathUnits to vectors: [v1, v2, ..., vn] */
    let vectors = pointsToVectors(points: points)
    
    /* compute average direction vector */
    let averVector = computeAverVector(vectors: vectors)
    
    /* rotate axes so that X axis is parallel to averVector */
    let alpha = atan(averVector.y / averVector.x) // rotate by z
    
    let beta = atan(averVector.z / pow(averVector.x * averVector.x + averVector.y * averVector.y, 0.5)) // rotate by y
    
    var rotatedPoints: [Point] = []
    for point in points {
        rotatedPoints.append(rotate(point: point, alpha: alpha, beta: beta))
    }
    
    /* lines for sweeping */
    var rotatedLines: [[Point]] = []
    var index = 0
    while(index <= rotatedPoints.count - 2) {
        if(rotatedPoints[index].x > rotatedPoints[index+1].x) {
            rotatedLines.append([rotatedPoints[index+1], rotatedPoints[index]])
        } else {
            rotatedLines.append([rotatedPoints[index], rotatedPoints[index+1]])
        }
        index += 2
    }
    
    /* sort points by x value */
    points.sort { (p1: Point, p2: Point) -> Bool in
        return p1.x < p2.x
    }
    rotatedLines.sort { (l1: [Point], l2: [Point]) -> Bool in
        return l1[0].x < l2[0].x
    }
    
    var lastXValue = points[0].x - r
    for point in points {
        let values = pathUnitXValue(sweepPlane: point.x, lines: rotatedLines)
        if(values.count >= MinLns) {
            let diff = point.x - lastXValue
            lastXValue = point.x
            if(diff >= r) {
                var rotatedAverPoint = Point(x: 0, y: 0, z: 0)
                for value in values {
                    rotatedAverPoint = rotatedAverPoint + value
                }
                rotatedAverPoint = rotatedAverPoint / Double(values.count)
                /* undo rotation */
                let averPoint = unrotate(point: rotatedAverPoint, alpha: alpha, beta: beta)
                let representLocation = CLLocation(
                    coordinate: CLLocationCoordinate2D(
                        latitude: averPoint.x / laScale + pathUnits[0].start_point.coordinate.latitude,
                        longitude: averPoint.y / lgScale + pathUnits[0].start_point.coordinate.longitude),
                    altitude: averPoint.z + pathUnits[0].start_point.altitude,
                    horizontalAccuracy: -1, verticalAccuracy: -1, timestamp: Date(timeIntervalSince1970: 1))
                representLocations.append(representLocation)
            }
        }
    }
    return representLocations
}

func pathUnitXValue(sweepPlane: Double, lines: [[Point]]) -> [Point] {
    var values: [Point] = []
    for line in lines {
        if(line[0].x == sweepPlane) {
            values.append(line[0])
            break
        } else if(line[1].x == sweepPlane) {
            values.append(line[1])
            break
        }
    }
    for line in lines {
        if(line[0].x < sweepPlane && line[1].x > sweepPlane) {
            let p = Point(
                x: sweepPlane,
                y: (sweepPlane - line[0].x) / (line[1].x - line[0].x) * (line[1].y - line[0].y) + line[0].y,
                z: (sweepPlane - line[0].x) / (line[1].x - line[0].x) * (line[1].z - line[0].z) + line[0].z)
            values.append(p)
        }
    }
    return values
}
