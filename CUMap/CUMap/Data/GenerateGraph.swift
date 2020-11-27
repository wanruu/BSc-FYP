//
//  PreProcess.swift
//  CUMap
//
//  Created by wanruuu on 27/11/2020.
//

import Foundation

let laScale = 111000.0
let lgScale = 85390.0

/* calculate distance between two location */
func distance(start: LocationData, end: LocationData) -> Double {
    let diffX = (start.latitude - end.latitude) * laScale
    let diffY = (start.longitude - end.longitude) * lgScale
    let diffZ = start.altitude - end.altitude
    let dist = pow(diffX * diffX + diffY * diffY + diffZ * diffZ, 0.5)
    return dist
}

func distance(start: LocationData, end: PathPoint) -> Double {
    let diffX = (start.latitude - end.latitude) * laScale
    let diffY = (start.longitude - end.longitude) * lgScale
    let diffZ = start.altitude - end.altitude
    let dist = pow(diffX * diffX + diffY * diffY + diffZ * diffZ, 0.5)
    return dist
}

func distance(start: PathPoint, end: PathPoint) -> Double {
    let diffX = (start.latitude - end.latitude) * laScale
    let diffY = (start.longitude - end.longitude) * lgScale
    let diffZ = start.altitude - end.altitude
    let dist = pow(diffX * diffX + diffY * diffY + diffZ * diffZ, 0.5)
    return dist
}

/* find the nearest pathpoint from a location */
func nearestPathPoint(location: LocationData, paths: [[PathPoint]]) -> (Int, Int) {
    var row = 0
    var col = 0
    var min = 100.0
    for i in 0..<paths.count {
        for j in 0..<paths[i].count {
            if(distance(start: location, end: paths[i][j]) < min) {
                min = distance(start: location, end: paths[i][j])
                row = i
                col = j
            }
        }
    }
    return (row, col)
}
/* pathpoint distance less than 5.0m will be regarded to be connected */
let MIN_DIST = 10.0
func connectTwoPath(paths: [[PathPoint]]) -> [[PathPoint]] {
    var result: [[PathPoint]] = []
    var flag = [Bool](repeating: false, count: paths.count) // whether connected
    for i in 0..<paths.count {
        if(flag[i]) {
            continue
        }
        for j in i+1..<paths.count {
            if(flag[j]) {
                continue
            }
            if(distance(start: paths[i][0], end: paths[j][0]) <= MIN_DIST) {
                result.append(paths[i].reversed() + paths[j])
                flag[i] = true
                flag[j] = true
                break
            }
            if(distance(start: paths[i][0], end: paths[j][paths[j].count-1]) <= MIN_DIST) {
                result.append(paths[j] + paths[j])
                flag[i] = true
                flag[j] = true
                break
            }
            if(distance(start: paths[i][paths[i].count-1], end: paths[j][paths[j].count-1]) <= MIN_DIST) {
                result.append(paths[i] + paths[j].reversed())
                flag[i] = true
                flag[j] = true
                break
            }
            if(distance(start: paths[i][paths[i].count-1], end: paths[j][0]) <= MIN_DIST) {
                result.append(paths[i] + paths[j])
                flag[i] = true
                flag[j] = true
                break
            }
        }
    }
    for i in 0..<flag.count {
        if(!flag[i]) {
            result.append(paths[i])
        }
    }
    return result
}

func canConnect(paths: [[PathPoint]]) -> Bool {
    for i in 0..<paths.count {
        for j in i+1..<paths.count {
            if(distance(start: paths[i][0], end: paths[j][0]) <= MIN_DIST ||
                distance(start: paths[i][0], end: paths[j][paths[j].count-1]) <= MIN_DIST ||
                distance(start: paths[i][paths[i].count-1], end: paths[j][paths[j].count-1]) <= MIN_DIST ||
                distance(start: paths[i][paths[i].count-1], end: paths[j][0]) <= MIN_DIST) {
                return true
            }
        }
    }
    return false
}

func connectPath(paths: [[PathPoint]]) -> [[PathPoint]] {
    var result = paths
    while(canConnect(paths: paths)) {
        result = connectTwoPath(paths: result)
    }
    return result
}
