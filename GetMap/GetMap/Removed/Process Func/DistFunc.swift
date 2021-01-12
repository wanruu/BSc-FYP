import Foundation

// MARK: - distance function: calculate distance between p1p2 and p3p4
func computeDistance(locations: [Coor3D]) -> Distance {
    /* ensure input parameters are valid */
    if(locations.count != 4) {
        fatalError("Parameter error in function distance.")
    }
    
    /* ensure p1p2 > p3p4 */
    let dist1 = (locations[0].altitude - locations[1].altitude) * (locations[0].altitude - locations[1].altitude) +
        (locations[0].latitude - locations[1].latitude) * laScale * (locations[0].latitude - locations[1].latitude) * laScale +
        (locations[0].longitude - locations[1].longitude) * lgScale * (locations[0].longitude - locations[1].longitude) * lgScale
    let dist2 = (locations[2].altitude - locations[3].altitude) * (locations[2].altitude - locations[3].altitude) +
        (locations[2].latitude - locations[3].latitude) * laScale * (locations[2].latitude - locations[3].latitude) * laScale +
        (locations[2].longitude - locations[3].longitude) * lgScale * (locations[2].longitude - locations[3].longitude) * lgScale
    
    /* change CLLocation to coordinate */
    var points : [Point] = []
    points.append(Point(x: 0, y: 0, z: 0)) // regard points[0] as origin
    
    if(dist1 < dist2) {
        for index in [2, 1, 0] {
            let point = Point(
                x: (locations[index].latitude - locations[3].latitude) * laScale,
                y: (locations[index].longitude - locations[3].longitude) * lgScale,
                z: locations[index].altitude - locations[3].altitude)
            points.append(point)
        }
    } else {
        for index in [1, 2, 3] {
            let point = Point(
                x: (locations[index].latitude - locations[0].latitude) * laScale,
                y: (locations[index].longitude - locations[0].longitude) * lgScale,
                z: locations[index].altitude - locations[0].altitude)
            points.append(point)
        }
    }
    
    /* calculate something for later computing */
    let length1 = dist(start: points[0], end: points[1]) // length of p1p2
    let length2 = dist(start: points[2], end: points[3]) // length of p3p4
    let proj_p3 = ((points[2] * points[1]) / length1 / length1) * points[1] // projection point of p3 onto p1p2
    let proj_p4 = ((points[3] * points[1]) / length1 / length1) * points[1] // projection point of p4 onto p1p2
    let theta = acos(points[1] * (points[3] - points[2]) / length1 / length2)
    /* perpendicular distance */
    let l_perp1 = dist(start: proj_p3, end: points[2])
    let l_perp2 = dist(start: proj_p4, end: points[3])
    let perp = (l_perp1 * l_perp1 + l_perp2 * l_perp2) / (l_perp1 + l_perp2)
    /* parallel distance */
    let l_para1 = min(dist(start: proj_p3, end: points[0]), dist(start: proj_p3, end: points[1]))
    let l_para2 = min(dist(start: proj_p4, end: points[0]), dist(start: proj_p4, end: points[1]))
    let parallel = min(l_para1, l_para2)
    /* angle distance: no direction */
    let angle = length2 * sin(theta)
    return Distance(perpendicular: perp, parallel: parallel, angle: angle)
}

/* weighted distance */
func weightedDistance(locations: [Coor3D]) -> Double {
    let dist = computeDistance(locations: locations)
    // TODO: change the weight
    return 0.8 * dist.perpendicular + dist.parallel + dist.angle
}


// MARK: - Point Data Structure
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

func dist(start: Point, end: Point) -> Double {
    return pow(
        (start.x - end.x) * (start.x - end.x) +
        (start.y - end.y) * (start.y - end.y) +
        (start.z - end.z) * (start.z - end.z), 0.5)
}

// MARK: - Distance Data Structure
struct Distance {
    var perpendicular: Double
    var parallel: Double
    var angle: Double
}
