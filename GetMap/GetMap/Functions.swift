//
//  Functions.swift
//  GetMap
//
//  Created by wanruuu on 31/10/2020.
//

import Foundation
import CoreLocation

/* trajectory partitioning */
func MDLPar(path: [CLLocation], startIndex: Int, endIndex: Int) -> Double {
    /* only two cp in this trajectory */
    /* distance between two charateristic points */
    var angleSum = 0.0
    var perpSum = 0.0
    let x1: Double = path[startIndex].coordinate.latitude
    let y1: Double = path[startIndex].coordinate.longitude
    let x2: Double = path[endIndex].coordinate.latitude
    let y2: Double = path[endIndex].coordinate.longitude
    let diffX: Double = x1 - x2
    let diffY: Double = y1 - y2

    for index in startIndex...(endIndex - 1) {
        /* line: (x1 - x2)(y - y1) - (y1 - y2)*(x - x1) = 0 */
        let xi = path[index].coordinate.latitude
        let yi = path[index].coordinate.longitude
        let xii = path[index + 1].coordinate.latitude
        let yii = path[index + 1].coordinate.longitude
        /* perpendicular distance */
        let tmp = pow(diffX*diffX+diffY*diffY, 0.5)
        let pd1 = abs(diffX*(yi-y1)-diffY*(xi-x1)) / tmp
        let pd2 = abs(diffX*(yii-y1)-diffY*(xii-x1)) / tmp
        perpSum += (pd1*pd1+pd2*pd2)/(pd1+pd2)
        /* angle distance */
        angleSum += abs(pd2 - pd1)
    }
    let LH: Double = log2(pow(diffX*diffX+diffY*diffY, 0.5))
    let LH_D = log2(angleSum) + log2(perpSum)
    return LH + LH_D
}

func MDLNotPar(path: [CLLocation], startIndex: Int, endIndex: Int) -> Double {
    var LH: Double = 0
    // LH_D = 0 under this situation
    for index in startIndex...(endIndex - 1) {
        let diffX: Double = path[index].coordinate.latitude - path[index+1].coordinate.latitude
        let diffY: Double = path[index].coordinate.longitude - path[index+1].coordinate.longitude
        LH += log2(pow(diffX*diffX+diffY*diffY, 0.5))
    }
    return LH
}
