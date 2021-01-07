// Aim: To generate routes from given connected representative trajs


import Foundation

// main function
func generateRoutes(trajs: [[Coor3D]], locations: [Location]) -> [Route] {
    var routes: [Route] = []
    
    // Step 1: preprocess. split trajs
    var closestPoints = [Coor3D](repeating: Coor3D(latitude: -1, longitude: -1, altitude: -1), count: locations.count)
    for i in 0..<locations.count {
        closestPoints[i] = findClosestPoint(location: locations[i], trajs: trajs)
    }
    let processedTrajs = splitTrajs(trajs: trajs, points: closestPoints)
    
    // Step 2: add direct route between two locations to route
    for traj in processedTrajs { // for each traj
        if traj.count < 2 {
            continue
        }
        let startP = traj.first!
        let endP = traj.last!
        let startIndex = closestPoints.firstIndex(of: startP)
        let endIndex = closestPoints.firstIndex(of: endP)
        if startIndex == nil || endIndex == nil || startIndex == endIndex {
            continue
        }
        let startLoc = locations[startIndex!]
        let endLoc = locations[endIndex!]
        let points = [Coor3D(latitude: startLoc.latitude, longitude: startLoc.longitude, altitude: startLoc.altitude)] + traj + [Coor3D(latitude: endLoc.latitude, longitude: endLoc.longitude, altitude: endLoc.altitude)]
        var dist = 0.0
        for i in 0..<points.count - 1 {
            dist += distance(start: points[i], end: points[i+1])
        }
        
        routes.append(Route(_id: "", startLoc: startLoc, endLoc: endLoc, points: points, dist: dist, type: [0]))
    }
    
    // Step 3: remove checked traj in step 2
    
    return routes
}

// split trajs with given points
func splitTrajs(trajs: [[Coor3D]], points: [Coor3D]) -> [[Coor3D]] {
    var result: [[Coor3D]] = []
    
    for traj in trajs { // for each traj
        // mark at which index should be splited
        var marks: [Int] = []
        marks.append(0)
        for i in 1..<traj.count-1 { // for each point
            if points.contains(traj[i]) { // need to split
                marks.append(i)
            }
        }
        marks.append(traj.count-1)

        // start split
        for i in 0..<marks.count-1 {
            result.append(Array(traj[marks[i]...marks[i+1]]))
        }

    }
    return result
}


// find closest point from location in trajs
func findClosestPoint(location: Location, trajs: [[Coor3D]]) -> Coor3D {
    var minDist = INF
    var closestPoint = trajs[0][0]
    for traj in trajs {
        for point in traj {
            let dist = distance(location: location, point: point)
            if(dist < minDist) {
                minDist = dist
                closestPoint = point
            }
        }
    }
    return closestPoint
}
