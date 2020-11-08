//
//  Functions.swift
//  GetMap
//
//  Created by wanruuu on 31/10/2020.
//

import Foundation
import CoreLocation

// MARK: - trajectory partitioning
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

func MDLPar(path: [CLLocation], startIndex: Int, endIndex: Int) -> Double {
    /* only two cp in this trajectory */
    /* distance between two charateristic points */
    var angleSum = 0.0
    var perpSum = 0.0

    let diffX = (path[startIndex].coordinate.latitude - path[endIndex].coordinate.latitude) * laScale
    let diffY = (path[startIndex].coordinate.longitude - path[endIndex].coordinate.longitude) * lgScale
    let diffZ = path[startIndex].altitude - path[endIndex].altitude

    for index in startIndex...(endIndex - 1) {
        let dist = computDistance(locations: [path[startIndex], path[endIndex], path[index], path[index+1]])
        /* perpendicular distance */
        perpSum += dist.perpendicular
        /* angle distance */
        angleSum += dist.angle
    }
    let LH: Double = log2( pow( diffX * diffX + diffY * diffY + diffZ * diffZ, 0.5 ) )
    let LH_D = log2(angleSum) + log2(perpSum)
    return LH + LH_D
}

func MDLNotPar(path: [CLLocation], startIndex: Int, endIndex: Int) -> Double {
    var LH: Double = 0
    // LH_D = 0 under this situation
    for index in startIndex...(endIndex - 1) {
        let diffX: Double = (path[index].coordinate.latitude - path[index+1].coordinate.latitude) * laScale
        let diffY: Double = (path[index].coordinate.longitude - path[index+1].coordinate.longitude) * lgScale
        let diffZ: Double = path[index].altitude - path[index+1].altitude
        LH += pow( diffX * diffX + diffY * diffY + diffZ * diffZ, 0.5 )
    }
    return log2(LH)
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
    /* ensure input parameters are valid */
    if(locations.count != 4) {
        fatalError("Parameter error in function distance.")
    }

    /* ensure p1p2 > p3p4 */
    let dist1 = (locations[0].altitude - locations[1].altitude) * (locations[0].altitude - locations[1].altitude) +
        (locations[0].coordinate.latitude - locations[1].coordinate.latitude) * laScale * (locations[0].coordinate.latitude - locations[1].coordinate.latitude) * laScale +
        (locations[0].coordinate.longitude - locations[1].coordinate.longitude) * lgScale * (locations[0].coordinate.longitude - locations[1].coordinate.longitude) * lgScale
    let dist2 = (locations[2].altitude - locations[3].altitude) * (locations[2].altitude - locations[3].altitude) +
        (locations[2].coordinate.latitude - locations[3].coordinate.latitude) * laScale * (locations[2].coordinate.latitude - locations[3].coordinate.latitude) * laScale +
        (locations[2].coordinate.longitude - locations[3].coordinate.longitude) * lgScale * (locations[2].coordinate.longitude - locations[3].coordinate.longitude) * lgScale
    
    /* change CLLocation to coordinate */
    var points : [Point] = []
    points.append(Point(x: 0, y: 0, z: 0)) // regard points[0] as origin
    
    if(dist1 < dist2) {
        for index in [2, 1, 0] {
            let point = Point(
                x: (locations[index].coordinate.latitude - locations[3].coordinate.latitude) * laScale,
                y: (locations[index].coordinate.longitude - locations[3].coordinate.longitude) * lgScale,
                z: locations[index].altitude - locations[3].altitude)
            points.append(point)
        }
    } else {
        for index in [1, 2, 3] {
            let point = Point(
                x: (locations[index].coordinate.latitude - locations[0].coordinate.latitude) * laScale,
                y: (locations[index].coordinate.longitude - locations[0].coordinate.longitude) * lgScale,
                z: locations[index].altitude - locations[0].altitude)
            points.append(point)
        }
    }
    
    /* calculate something for later computing */
    let length1 = length(start: points[0], end: points[1]) // length of p1p2
    let length2 = length(start: points[2], end: points[3]) // length of p3p4
    let proj_p3 = ((points[2] * points[1]) / length1 / length1) * points[1] // projection point of p3 onto p1p2
    let proj_p4 = ((points[3] * points[1]) / length1 / length1) * points[1] // projection point of p4 onto p1p2
    let theta = acos(points[1] * (points[3] - points[2]) / length1 / length2)
    /* perpendicular distance */
    let l_perp1 = length(start: proj_p3, end: points[2])
    let l_perp2 = length(start: proj_p4, end: points[3])
    let perp = (l_perp1 * l_perp1 + l_perp2 * l_perp2) / (l_perp1 + l_perp2)
    /* parallel distance */
    let l_para1 = min(length(start: proj_p3, end: points[0]), length(start: proj_p3, end: points[1]))
    let l_para2 = min(length(start: proj_p4, end: points[0]), length(start: proj_p4, end: points[1]))
    let parallel = min(l_para1, l_para2)
    /* angle distance: no direction */
    let angle = length2 * sin(theta)
    return Distance(perpendicular: perp, parallel: parallel, angle: angle)
}

func partition(path: [CLLocation]) -> [CLLocation] {
    /* characteristic points */
    var cp: [CLLocation] = []
    /* add starting point to cp */
    cp.append(path[0])
    var startIndex = 0
    var length = 1
    while (startIndex + length <= path.count - 1) {
        let currIndex = startIndex + length
        /* cost if regard current point as charateristic point */
        let costPar = MDLPar(path: path, startIndex: startIndex, endIndex: currIndex)
        /* cost if not regard current point as charateristic point */
        let costNotPar = MDLNotPar(path: path, startIndex: startIndex, endIndex: currIndex)
        // print(startIndex, currIndex, costPar, costNotPar)
        if(costPar > costNotPar) {
            /* add previous point to cp */
            cp.append(path[currIndex - 1])
            startIndex = currIndex - 1
            length = 1
        } else {
            length += 1
        }
    }
    /* add ending point to cp */
    cp.append(path[path.count - 1])
    return cp
}

// MARK: - trajectory clustering

/* weighted distance */
func weightedDistance(locations: [CLLocation]) -> Double {
    let dist = computDistance(locations: locations)
    // TODO: change the weight
    return dist.perpendicular + dist.parallel + dist.angle
}

let e: Double = 10
let MinLns: Int = 3

/* calculate e-neighborhood for every path unit */
func neighbor(pathUnits: [PathUnit]) -> [[Int]] {
    var result = [[Int]](repeating: [], count: pathUnits.count)
    for i in 0..<pathUnits.count {
        for j in (i+1)..<pathUnits.count {
            let dist = weightedDistance(locations: [pathUnits[i].start_point, pathUnits[i].end_point, pathUnits[j].start_point, pathUnits[j].end_point])
            if(dist <= e) {
                result[i].append(j)
                result[j].append(i)
            }
        }
    }
    return result
}
func cluster(pathUnits: [PathUnit]) -> [Int] {
    var clusterId = 1
    /* 0: unclassfied, -1: noise, others: clusterId */
    var cluster = [Int](repeating: 0, count: pathUnits.count)
    /* compute neighbor array */
    let neighborList = neighbor(pathUnits: pathUnits)
    
    /* for each path unit */
    for index in 0..<pathUnits.count {
        if(cluster[index] == 0) { // not classfied
            let neighbors = neighborList[index]
            /* core line segment */
            if(neighbors.count + 1 >= MinLns) {
                /* assgin clusterId to each neighbor */
                cluster[index] = clusterId
                for neighbor in neighbors {
                    cluster[neighbor] = clusterId
                }
                /* expand cluster */
                var queue = neighbors
                while(queue.count != 0) {
                    let first = queue[0] // first is the first path unit in queue
                    let firstNeighbors = neighborList[first] // get neighbor of first, first not included
                    if(firstNeighbors.count >= MinLns) {
                        for neighbor in firstNeighbors {
                            if(cluster[neighbor] == 0 || cluster[neighbor] == -1) {
                                cluster[neighbor] = clusterId
                            }
                            if(cluster[neighbor] == 0) {
                                queue.append(neighbor)
                            }
                        }
                    }
                    queue.removeFirst()
                }
                clusterId += 1
            }
            /* mark as noise */
            else {
                cluster[index] = -1
            }
        }
    }
    /* check trajectory cardinality */
    var cardinality = [Int](repeating: 0, count: clusterId)
    for c in cluster {
        if(c != -1) {
            cardinality[c] += 1
        }
    }
    for i in 0..<cluster.count-1 {
        if(cluster[i] != -1 && cardinality[cluster[i]] < MinLns) {
            cluster[i] = -1
        }
    }
    return cluster
}

// MARK: - generate representative trajectory
let r = 1.0

/* convert location to point */
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

/* convert pathUnits to vectors: [v1, v2, ..., vn] */
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
    var z = 0.0
    for vector in vectors {
        x += abs(vector.x)
        y += abs(vector.y)
        z += abs(vector.z)
    }
    if(x > y && x > z) { // x: max
        for index in 0..<vectors.count-1 {
            if(vectors[index].x * vectors[0].x < 0) {
                averVector = averVector - vectors[index]
            } else {
                averVector = averVector + vectors[index]
            }
        }
    } else if(y > x && y > z) { // y: max
        for index in 0..<vectors.count-1 {
            if(vectors[index].y * vectors[0].y < 0) {
                averVector = averVector - vectors[index]
            } else {
                averVector = averVector + vectors[index]
            }
        }
    } else { // z: max
        for index in 0..<vectors.count-1 {
            if(vectors[index].z * vectors[0].z < 0) {
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
func rotate(point: Point, alpha: Double, beta: Double) -> Point {
    var newPoint = Point(x: point.x, y: point.y, z: point.z)
    newPoint.x = newPoint.x * cos(alpha) - newPoint.y * sin(alpha)
    newPoint.y = newPoint.y * cos(alpha) + newPoint.x * sin(alpha)
    newPoint.x = newPoint.x * cos(beta) + newPoint.z * sin(beta)
    newPoint.z = -newPoint.x * sin(beta) + newPoint.z * cos(beta)
    return newPoint
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
    let alpha = atan(averVector.x / averVector.y) + .pi * 3 / 2 // 绕z
    
    let beta = atan(averVector.z / pow(averVector.x * averVector.x + averVector.y * averVector.y, 0.5)) // 绕y
    
    var rotatedPoints: [Point] = []
    for point in points {
        rotatedPoints.append(rotate(point: point, alpha: alpha, beta: beta))
    }
    
    /* lines for sweeping */
    var rotatedLines: [[Point]] = []
    var index = 0
    while(index <= points.count - 2) {
        if(points[index].x > points[index+1].x) {
            rotatedLines.append([points[index+1], points[index]])
        } else {
            rotatedLines.append([points[index], points[index+1]])
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
    
    var lastXValue = points[0].x
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
                let averPoint = rotate(point: rotatedAverPoint, alpha: .pi * 2 - alpha, beta: .pi * 2 - beta)
                
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
        if(line[0].x <= sweepPlane && line[1].x >= sweepPlane) {
            let p = Point(
                x: sweepPlane,
                y: (sweepPlane - line[0].x) / (line[1].x - line[0].x) * (line[1].y - line[0].y) + line[0].y,
                z: (sweepPlane - line[0].x) / (line[1].x - line[0].x) * (line[1].z - line[0].z) + line[0].z)
            values.append(p)
        }
    }
    return values
}
