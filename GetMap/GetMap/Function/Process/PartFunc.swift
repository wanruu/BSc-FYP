/* MARK: Trajectory Partitioning */

import Foundation
import CoreLocation

func MDLPar(path: [CLLocation], startIndex: Int, endIndex: Int) -> Double {
    /* only two cp in this trajectory */
    /* distance between two charateristic points */
    var angleSum = 0.0
    var perpSum = 0.0

    let diffX = (path[startIndex].coordinate.latitude - path[endIndex].coordinate.latitude) * laScale
    let diffY = (path[startIndex].coordinate.longitude - path[endIndex].coordinate.longitude) * lgScale
    let diffZ = path[startIndex].altitude - path[endIndex].altitude

    for index in startIndex...(endIndex - 1) {
        let dist = computDistance(locations: [path[startIndex], path[endIndex], path[index], path[index+1]])
        /* perpendicular distance */
        perpSum += dist.perpendicular
        /* angle distance */
        angleSum += dist.angle
    }
    let LH: Double = log2( pow( diffX * diffX + diffY * diffY + diffZ * diffZ, 0.5 ) )
    let LH_D = log2(angleSum) + log2(perpSum)
    return LH + LH_D
}

func MDLNotPar(path: [CLLocation], startIndex: Int, endIndex: Int) -> Double {
    var LH: Double = 0
    // LH_D = 0 under this situation
    for index in startIndex...(endIndex - 1) {
        let diffX: Double = (path[index].coordinate.latitude - path[index+1].coordinate.latitude) * laScale
        let diffY: Double = (path[index].coordinate.longitude - path[index+1].coordinate.longitude) * lgScale
        let diffZ: Double = path[index].altitude - path[index+1].altitude
        LH += pow( diffX * diffX + diffY * diffY + diffZ * diffZ, 0.5 )
    }
    return log2(LH)
}

func partition(path: [CLLocation]) -> [CLLocation] {
    /* characteristic points */
    var cp: [CLLocation] = []
    /* add starting point to cp */
    cp.append(path[0])
    var startIndex = 0
    var length = 1
    while (startIndex + length <= path.count - 1) {
        let currIndex = startIndex + length
        /* cost if regard current point as charateristic point */
        let costPar = MDLPar(path: path, startIndex: startIndex, endIndex: currIndex)
        /* cost if not regard current point as charateristic point */
        let costNotPar = MDLNotPar(path: path, startIndex: startIndex, endIndex: currIndex)
        // print(startIndex, currIndex, costPar, costNotPar)
        if(costPar > costNotPar) {
            /* add previous point to cp */
            cp.append(path[currIndex - 1])
            startIndex = currIndex - 1
            length = 1
        } else {
            length += 1
        }
    }
    /* add ending point to cp */
    cp.append(path[path.count - 1])
    return cp
}
