import Foundation

let MinDist = 20.0

func findNeighbors(trajs: [[Coor3D]]) -> [[[(Int, Int)]]] {
    /* Step 1: initialize return result */
    var neighbors: [[[(Int, Int)]]] = [[[(Int, Int)]]](repeating: [], count: trajs.count)
    for i in 0..<trajs.count {
        neighbors[i] = [[(Int, Int)]](repeating: [], count: trajs[i].count)
    }
    
    /* Step 2: find neighbors */
    for i in 0..<trajs.count { // for each trajectory
        let start = trajs[i][0]
        let end = trajs[i][trajs[i].count - 1]
        for j in i+1..<trajs.count { // next trajectory
            for k in 0..<trajs[j].count { // next point to consider
                let point = trajs[j][k]
                if(distance(start: start, end: point) <= MinDist) {
                    neighbors[i][0].append((j, k))
                    neighbors[j][k].append((i, 0))
                }
                if(distance(start: end, end: point) <= MinDist) {
                    neighbors[i][trajs[i].count - 1].append((j, k))
                    neighbors[j][k].append((i, trajs[i].count - 1))
                }
            }
        }
    }
    return neighbors
}

func connect(trajs: [[Coor3D]]) -> [[Coor3D]] { // by clustering
    var result = trajs
    /* Step 1: find neighbors of each point */
    let neighborList = findNeighbors(trajs: trajs)
    
    /* Step 2: cluster */
    var cluster = [[Int]](repeating: [], count: trajs.count)
    for i in 0..<trajs.count {
        cluster[i] = [Int](repeating: 0, count: trajs[i].count)
    }
    var clusterId = 1
    
    for i in 0..<trajs.count {
        for j in 0..<trajs[i].count { // for each point
            if(cluster[i][j] == 0) { // not classfied
                let neighbors = neighborList[i][j]
                if(neighbors.count >= 2) {
                    // assgin clusterId to each neighbor
                    cluster[i][j] = clusterId
                    for (n_i, n_j) in neighbors {
                        cluster[n_i][n_j] = clusterId
                    }
                    // expand cluster
                    var queue = neighbors
                    while(queue.count != 0) {
                        let (first_i, first_j) = queue[0] // (Int, Int)
                        let firstNeighbors = neighborList[first_i][first_j]
                        if(firstNeighbors.count >= 2) {
                            for (n_i, n_j) in firstNeighbors {
                                if(cluster[n_i][n_j] == 0 || cluster[n_i][n_j] == -1) {
                                    cluster[n_i][n_j] = clusterId
                                }
                                if(cluster[n_i][n_j] == 0) {
                                    queue.append((n_i, n_j))
                                }
                            }
                        }
                        queue.removeFirst()
                    }
                    clusterId += 1
                } else {
                    cluster[i][j] = -1
                }
            }
        }
    }
    
    /* Step 3: calculate average point for each cluster */
    var averagePoints = [Coor3D](repeating: Coor3D(latitude: 0, longitude: 0, altitude: 0), count: clusterId)
    var nums = [Int](repeating: 0, count: clusterId)
    for i in 0..<trajs.count {
        for j in 0..<trajs[i].count { // for each point
            let id = cluster[i][j]
            guard id >= 1 else {
                continue
            }
            averagePoints[id-1] = averagePoints[id-1] + trajs[i][j]
            nums[id-1] += 1
        }
    }
    for i in 0..<clusterId {
        averagePoints[i] = averagePoints[i] / nums[i]
    }

    /* Step 4: connect */
    for i in 0..<result.count {
        for j in 0..<result[i].count { // for each point
            let id = cluster[i][j]
            guard id >= 1 else {
                continue
            }
            result[i][j] = averagePoints[id-1]
        }
    }

    return result
}

