/* MARK: Trajectory Clustering */

import Foundation
import CoreLocation

let e: Double = 13
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
    for i in 0..<cluster.count {
        if(cluster[i] != -1 && cardinality[cluster[i]] < MinLns) {
            cluster[i] = -1
        }
    }
    return cluster
}
