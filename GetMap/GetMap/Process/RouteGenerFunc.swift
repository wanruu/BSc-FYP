// Aim: To generate routes from given connected representative trajs


import Foundation

// main function
func GenerateRoutes(trajs: [[Coor3D]], locations: [Location]) -> [Route] {
    var routes: [Route] = []

    return routes
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
