
import Foundation

func findClosestPoint(location: Location, trajs: [[Coor3D]]) -> (Double, Int, Int) {
    var minDist = 999.0
    var min_i = -1
    var min_j = -1
    for i in 0..<trajs.count {
        for j in 0..<trajs[i].count {
            let dist = distance(location: location, point: trajs[i][j])
            if(dist < minDist) {
                minDist = dist
                min_i = i
                min_j = j
            }
        }
    }
    return (minDist, min_i, min_j)
}

struct Path1 {
    var points: [Coor3D]
    var dist: Double
}

// not contains distance from location to point
func findPathBetween(startLoc: Location, endLoc: Location, trajs: [[Coor3D]]) -> Path1 {
    /* Step 1: initialize priority queue */
    var priorityQueue: [Path1] = []
    let (_, start_i, start_j) = findClosestPoint(location: startLoc, trajs: trajs)
    let (_, end_i, end_j) = findClosestPoint(location: endLoc, trajs: trajs)
    priorityQueue.append(Path1(points: [trajs[start_i][start_j]], dist: 0))
    
    /* Step 2: initialize examined, whether this point has been examined */
    var examined = [[Bool]](repeating: [], count: trajs.count)
    for i in 0..<trajs.count {
        examined[i] = [Bool](repeating: false, count: trajs[i].count)
    }
    examined[start_i][start_j] = true
    
    /* Step 3: start */
    while(priorityQueue.count != 0 && priorityQueue[0].points.last != trajs[end_i][end_j]) {
        /* Step 4: find the PathBtwn with least dist (the first one) and remove it */
        let minPath = priorityQueue.remove(at: 0)
        
        /* Step 5: find its children and queue */
        for i in 0..<trajs.count {
            for j in 0..<trajs[i].count {
                if(trajs[i][j] == minPath.points.last!) { // find itself
                    // last element
                    if(j != 0 && !examined[i][j - 1]) {
                        let last = trajs[i][j - 1]
                        let dist = distance(start: last, end: minPath.points.last!)
                        var newPath = minPath
                        newPath.points.append(last)
                        newPath.dist += dist
                        priorityQueue.append(newPath)
                        examined[i][j - 1] = true
                    }
                    // next element
                    if(j != trajs[i].count - 1 && !examined[i][j + 1]) {
                        let next = trajs[i][j + 1]
                        let dist = distance(start: next, end: minPath.points.last!)
                        var newPath = minPath
                        newPath.points.append(next)
                        newPath.dist += dist
                        priorityQueue.append(newPath)
                        examined[i][j + 1] = true
                    }
                }
            }
        }
        /* Step 6: sort by dist for next loop */
        priorityQueue.sort{$0.dist < $1.dist}
    }
    /* Step 7: return */
    if(priorityQueue.count == 0) {
        return Path1(points: [], dist: -1)
    } else {
        return priorityQueue[0]
    }
}

func GenerateMapSys(trajs: [[Coor3D]], locations: [Location]) -> [Route] {
    var result: [Route] = []
    /* Step 1: initialize isPathFound - if the path between two locations has been found */
    var isPathFound = [[Bool]](repeating: [Bool](repeating: false, count: locations.count), count: locations.count)
    
    /* Step 2: find paths between every two locations */
    for i in 0..<locations.count {
        for j in i+1..<locations.count {
            if(isPathFound[i][j]) {
                continue
            }
            let path: Path1 = findPathBetween(startLoc: locations[i], endLoc: locations[j], trajs: trajs)
            let route = Route(id: "", startId: locations[i].id, endId: locations[j].id, points: path.points, dist: path.dist, type: 0)
            let paths = divide(route: route, locations: locations, trajs: trajs)
            for path in paths {
                let startLoc = locations.filter{$0.id == path.startId}[0]
                let startIndex = locations.firstIndex(of: startLoc)!
                let endLoc = locations.filter{$0.id == path.endId}[0]
                let endIndex = locations.firstIndex(of: endLoc)!

                isPathFound[startIndex][endIndex] = true
                isPathFound[endIndex][startIndex] = true
                result.append(path)
            }
        }
    }
    return result
}

func divide(route: Route, locations: [Location], trajs: [[Coor3D]]) -> [Route] {
    var result: [Route] = []
    var devisionSign: [(Int, Int, Double)] = []
    /* Step 1: calculate closest point for each location */
    var closestPoints: [(Double, Int, Int)] = []
    for location in locations {
        let closest = findClosestPoint(location: location, trajs: trajs)
        closestPoints.append(closest)
    }
    
    /* Step 2: sign */
    let points = route.points
    for i in 0..<points.count { // for each point to be divided
        for j in 0..<locations.count { // for each location
            let (closest_dist, closest_i, closest_j) = closestPoints[j]
            if(points[i] == trajs[closest_i][closest_j]) { // should divide here
                devisionSign.append((i, j, closest_dist))
            }
        }
    }
    
    /* Step 3: divide */
    var lastPointIndex = -1
    var lastLocIndex = -1
    var distSoFar = 0.0
    
    for index in 0..<devisionSign.count {
        let (pointIndex, locIndex, dist) = devisionSign[index]
        if(index == 0) {
            lastPointIndex = pointIndex
            lastLocIndex = locIndex
            distSoFar += dist
        } else {
            // calculate new dist
            distSoFar += dist
            for i in 0..<pointIndex - lastPointIndex {
                distSoFar += distance(start: points[lastPointIndex + i], end: points[lastPointIndex + i + 1])
            }
            // new points
            var newPoints: [Coor3D] = []
            for i in 0...pointIndex - lastPointIndex {
                newPoints.append(points[lastPointIndex + i])
            }
            let newRoute = Route(id: "", startId: locations[lastLocIndex].id, endId: locations[locIndex].id, points: newPoints, dist: distSoFar, type: 0)
            result.append(newRoute)
            lastPointIndex = pointIndex
            lastLocIndex = locIndex
            distSoFar = 0.0
        }
    }
    return result
}

