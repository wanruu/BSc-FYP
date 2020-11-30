//
//  Process.swift
//  GetMap
//
//  Created by wanruuu on 30/11/2020.
//

import Foundation

struct LineSeg {
    var start: Coor3D
    var end: Coor3D
    var clusterId: Int
}

func process(trajs: [[Coor3D]]) -> [[Coor3D]] {
    /* Step 1: partition */
    var lineSegs: [LineSeg] = []
    for traj in trajs {
        let cp = partition(traj: traj)
        for index in 0...cp.count-2 {
            let newLineSeg = LineSeg(start: cp[index], end: cp[index+1], clusterId: 0)
            lineSegs.append(newLineSeg)
        }
    }
    
    /* Step 2: cluster */
    let clusterIds = cluster(lineSegs: lineSegs)
    var clusterNum = 0
    for i in 0..<lineSegs.count {
        lineSegs[i].clusterId = clusterIds[i]
        clusterNum = max(clusterNum, clusterIds[i])
    }
    var clusters = [[LineSeg]](repeating: [], count: clusterNum)
    for i in 0..<lineSegs.count {
        if(clusterIds[i] != -1 && clusterIds[i] != 0) {
            clusters[clusterIds[i] - 1].append(lineSegs[i])
        }
    }
    
    /* Step 3: generate representative trajectory */
    var repTrajs: [[Coor3D]] = []
    for cluster in clusters {
        let repTraj = generateRepresent(lineSegs: cluster)
        if(repTraj.count >= 2) {
            repTrajs.append(repTraj)
        }
    }
    return repTrajs
    
    /* Step 4: */
}
