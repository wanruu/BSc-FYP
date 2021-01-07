import Foundation

let MinDist = 20.0

// main func
func smooth(trajs: [[Coor3D]]) -> [[Coor3D]] { // by clustering
    var result = trajs
    // Step 1: Find neighbors of each point
    let neighborList = findNeighbors(trajs: trajs)
    
    // Step 2: Cluster
    // cluster[i][j]. 0: unclustered, -1: noise, others: clusterId of trajs[i][j]
    var cluster = [[Int]](repeating: [], count: trajs.count)
    for i in 0..<trajs.count {
        cluster[i] = [Int](repeating: 0, count: trajs[i].count)
    }
    var clusterId = 1
    
    for i in 0..<trajs.count {
        for j in 0..<trajs[i].count { // for each point
            
            if cluster[i][j] != 0 { // if classfied
                continue
            }
            
            let neighbors = neighborList[i][j] // [(Int, Int)]
            if neighbors.count >= 2 { // it's core point
                // assgin clusterId to each neighbor
                cluster[i][j] = clusterId
                for (n_i, n_j) in neighbors {
                    cluster[n_i][n_j] = clusterId
                }
                // expand cluster to its neighbors' neighbors
                var queue = neighbors
                while queue.count != 0 {
                    let (first_i, first_j) = queue[0] // (Int, Int)
                    let firstNeighbors = neighborList[first_i][first_j]
                    if firstNeighbors.count >= 2 { // it's core point
                        for (n_i, n_j) in firstNeighbors {
                            if cluster[n_i][n_j] == 0 || cluster[n_i][n_j] == -1 {
                                cluster[n_i][n_j] = clusterId
                            }
                            if cluster[n_i][n_j] == 0 {
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
    
    // Step 3: Calculate average point for each cluster
    var averagePoints = [Coor3D](repeating: Coor3D(latitude: 0, longitude: 0, altitude: 0), count: clusterId - 1)
    var nums = [Int](repeating: 0, count: clusterId - 1) // number of points in each cluster
    for i in 0..<trajs.count {
        for j in 0..<trajs[i].count { // for each point
            let id = cluster[i][j]
            if id < 1 {
                continue
            }
            averagePoints[id-1] = averagePoints[id-1] + trajs[i][j]
            nums[id-1] += 1
        }
    }
    for i in 0..<clusterId - 1 {
        averagePoints[i] = averagePoints[i] / nums[i]
    }

    // Step 4: Replace each point with it's cluster's average point
    for i in 0..<result.count {
        for j in 0..<result[i].count { // for each point
            let id = cluster[i][j]
            if id < 1 {
                continue
            }
            result[i][j] = averagePoints[id-1]
        }
    }
    // also remove repeated point in one traj
    for i in 0..<result.count { // for each traj
        var index = 1 // index of current point
        var lastPoint = result[i][0]
        while index < result[i].count {
            if result[i][index] == lastPoint {
                result[i].remove(at: index)
            } else {
                lastPoint = result[i][index]
                index += 1
            }
        }
    }
    // remove traj whose size < 2
    var index = 0
    while index < result.count {
        if result[index].count < 2 {
            result.remove(at: index)
        } else {
            index += 1
        }
    }
    // recalculate nums: point number of each cluster
    nums = [Int](repeating: 0, count: clusterId - 1)
    for traj in result {
        for point in traj {
            let index = averagePoints.firstIndex(of: point)
            if index != nil {
                nums[index!] += 1
            }
        }
    }
    
    print("-----")
    for num in nums {
        if num > 2 {
            print(num)
        }
    }
    print("-----")
    
    // Step 5: Connect two traj with same endpoint.
    // This step can decrease num of representative trajs a lot, e.g, from 101 to 17
    var omitPoints: [Coor3D] = [] // crossroad
    for i in 0..<averagePoints.count {
        if nums[i] > 2 {
            omitPoints.append(averagePoints[i])
        }
    }
    var index1 = -1
    var index2 = -1
    (index1, index2) = connectIndex(trajs: result, omitPoints: omitPoints)
    
    while index1 != -1 && index2 != -1 {
        let traj1 = result.remove(at: index2)
        let traj2 = result.remove(at: index1)
        
        if traj1.first! == traj2.first! {
            var traj = traj1
            traj.removeFirst()
            traj.reverse()
            traj += traj2
            result.append(traj)
        } else if traj1.first! == traj2.last! {
            var traj = traj2
            traj.removeLast()
            traj += traj1
            result.append(traj)
        } else if traj1.last! == traj2.first! {
            var traj = traj1
            traj.removeLast()
            traj += traj2
            result.append(traj)
        } else if traj1.last! == traj2.last! {
            var traj = traj1
            traj.removeLast()
            traj.reverse()
            traj = traj2 + traj
            result.append(traj)
        }
        (index1, index2) = connectIndex(trajs: result, omitPoints: omitPoints)
    }

    
    
    print(result.count)
    
    var points: [Coor3D] = []
    var repeatCount = 0
    for traj in result {
        for point in traj {
            if !points.contains(point) {
                points.append(point)
            } else {
                repeatCount += 1
            }
        }
    }
    print("repeat point: \(repeatCount)")
    
    return result
}

func findNeighbors(trajs: [[Coor3D]]) -> [[[(Int, Int)]]] {
    // Step 1: initialize return result
    
    // neighbors[i][j][k] = (i', j'): a neighbor of trajs[i][j] is trajs[i'][j']
    var neighbors: [[[(Int, Int)]]] = [[[(Int, Int)]]](repeating: [], count: trajs.count)
    for i in 0..<trajs.count {
        neighbors[i] = [[(Int, Int)]](repeating: [], count: trajs[i].count)
    }
    
    // Step 2: find neighbors
    for i in 0..<trajs.count { // for each trajectory
        
        let start = trajs[i][0] // starting point of the trajectory
        let end = trajs[i][trajs[i].count - 1] // ending point of the trajectory
        
        for j in i+1..<trajs.count { // next trajectory
            for k in 0..<trajs[j].count { // for each point in next trajectory
                
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

// (index1, index2)
// trajs[index1] can be connected with trajs[index2]
func connectIndex(trajs: [[Coor3D]], omitPoints: [Coor3D]) -> (Int, Int) {
    for i in 0..<trajs.count {
        for j in i+1..<trajs.count {
            if !omitPoints.contains(trajs[i].first!) && (trajs[i].first! == trajs[j].first! || trajs[i].first! == trajs[j].last!) {
                return (i, j)
            }
            if !omitPoints.contains(trajs[i].last!) && (trajs[i].last! == trajs[j].first! || trajs[i].last! == trajs[j].last!) {
                return (i, j)
            }
        }
    }
    return (-1, -1)
}
