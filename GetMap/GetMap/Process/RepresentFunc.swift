/* MARK: Representative Trajectory Generation */

import Foundation

let r: Double = 1.5

// MARK: - compute average direction vector
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

// MARK: - generate representative trajectory
func generateRepresent(lineSegs: [LineSeg]) -> [Coor3D] {
    guard lineSegs.count > 0 else {
        return []
    }
    var represent: [Coor3D] = []
    
    /* convert pathUnits to points: [p1, p2, ..., p2n-1, p2n] where p1, p2 are start and end point of pathUnit[0] */
    let points = locationsToPoints(lineSegs: lineSegs)
    
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
    
    /* sort rotatedPoints by x value */
    rotatedPoints.sort { (p1: Point, p2: Point) -> Bool in
        return p1.x < p2.x
    }
    rotatedLines.sort { (l1: [Point], l2: [Point]) -> Bool in
        return l1[0].x < l2[0].x
    }
    
    /* start sweeping */
    var lastXValue = points[0].x - r
    for point in rotatedPoints {
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
                let representCoor3D = Coor3D(
                    latitude: averPoint.x / laScale + lineSegs[0].start.latitude,
                    longitude: averPoint.y / lgScale + lineSegs[0].start.longitude,
                    altitude: averPoint.z + lineSegs[0].start.altitude)
                represent.append(representCoor3D)
            }
        }
    }
    return represent
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

// MARK: - type translate
func locationsToPoints(lineSegs: [LineSeg]) -> [Point] {
    guard lineSegs.count > 0 else {
        return []
    }
    var points: [Point] = []
    // assume pathUnits[0].start_point as origin point
    let la = lineSegs[0].start.latitude
    let lg = lineSegs[0].start.longitude
    let al = lineSegs[0].start.altitude
    for lineSeg in lineSegs {
        points.append(Point(
            x: (lineSeg.start.latitude - la) * laScale,
            y: (lineSeg.start.longitude - lg) * lgScale,
            z: lineSeg.start.altitude - al))
        points.append(Point(
            x: (lineSeg.end.latitude - la) * laScale,
            y: (lineSeg.end.longitude - lg) * lgScale,
            z: lineSeg.end.altitude - al))
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

// MARK: - rotate & unrotate
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

