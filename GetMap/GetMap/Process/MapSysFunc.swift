//
//  MapSysFunc.swift
//  GetMap
//
//  Created by wanruuu on 2/12/2020.
//

import Foundation

func findClosestPoint(location: Location, trajs: [[Coor3D]]) -> (Double, Int, Int) {
    var minDist = 10.0
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

struct PathBtwn {
    var path: [Coor3D]
    var dist: Double
}

func findPathBetween(startLoc: Location, endLoc: Location, trajs: [[Coor3D]]) -> PathBtwn {
    /* initialize priority queue */
    var priorityQueue: [PathBtwn] = []
    let (startMinDist, start_i, start_j) = findClosestPoint(location: startLoc, trajs: trajs)
    let (endMinDist, end_i, end_j) = findClosestPoint(location: endLoc, trajs: trajs)
    priorityQueue.append(PathBtwn(path: [trajs[start_i][start_j]], dist: startMinDist))
    
    /* flag: whether this point has been examined */
    var examined = [[Bool]](repeating: [], count: trajs.count)
    for i in 0..<trajs.count {
        examined[i] = [Bool](repeating: false, count: trajs[i].count)
    }
    
    /* start */
    while(priorityQueue.count != 0 && priorityQueue[0].path.last != trajs[end_i][end_j]) {
        priorityQueue.sort{$0.dist < $1.dist} // sort by dist
        
        
        // TODO
        
    }
    if(priorityQueue.count == 0) {
        return PathBtwn(path: [], dist: -1)
    } else {
        return priorityQueue[0]
    }
}
