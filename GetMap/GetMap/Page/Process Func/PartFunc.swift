// MARK: Trajectory Partitioning

import Foundation

func MDLPar(traj: [Coor3D], startIndex: Int, endIndex: Int) -> Double {
    /* only two cp in this trajectory */
    /* distance between two charateristic points */
    var angleSum = 0.0
    var perpSum = 0.0

    let diffX = (traj[startIndex].latitude - traj[endIndex].latitude) * laScale
    let diffY = (traj[startIndex].longitude - traj[endIndex].longitude) * lgScale
    let diffZ = traj[startIndex].altitude - traj[endIndex].altitude

    for index in startIndex...(endIndex - 1) {
        let dist = computeDistance(locations: [traj[startIndex], traj[endIndex], traj[index], traj[index+1]])
        /* perpendicular distance */
        perpSum += dist.perpendicular
        /* angle distance */
        angleSum += dist.angle
    }
    let LH = log2(pow(diffX * diffX + diffY * diffY + diffZ * diffZ, 0.5))
    let LH_D = log2(angleSum) + log2(perpSum)
    return LH + 0.08*LH_D
}

func MDLNotPar(traj: [Coor3D], startIndex: Int, endIndex: Int) -> Double {
    var LH = 0.0
    // LH_D = 0 under this situation
    for index in startIndex...(endIndex - 1) {
        let diffX: Double = (traj[index].latitude - traj[index+1].latitude) * laScale
        let diffY: Double = (traj[index].longitude - traj[index+1].longitude) * lgScale
        let diffZ: Double = traj[index].altitude - traj[index+1].altitude
        LH += pow(diffX * diffX + diffY * diffY + diffZ * diffZ, 0.5)
    }
    return log2(LH)
}

func partition(traj: [Coor3D]) -> [Coor3D] {
    /* characteristic points */
    var cp: [Coor3D] = []
    /* add starting point to cp */
    cp.append(traj[0])
    var startIndex = 0
    var length = 1
    while (startIndex + length <= traj.count - 1) {
        let currIndex = startIndex + length
        /* cost if regard current point as charateristic point */
        let costPar = MDLPar(traj: traj, startIndex: startIndex, endIndex: currIndex)
        /* cost if not regard current point as charateristic point */
        let costNotPar = MDLNotPar(traj: traj, startIndex: startIndex, endIndex: currIndex)
        // print(startIndex, currIndex, costPar, costNotPar)
        if(costPar > costNotPar) {
            /* add previous point to cp */
            cp.append(traj[currIndex - 1])
            startIndex = currIndex - 1
            length = 1
        } else {
            length += 1
        }
    }
    /* add ending point to cp */
    cp.append(traj[traj.count - 1])
    return cp
}

