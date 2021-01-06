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
