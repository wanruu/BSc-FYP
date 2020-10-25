//
//  Point.swift
//  GetMap
//
//  Created by wanruuu on 25/10/2020.
//

import Foundation

/* data structure of a location point */
struct Point: Equatable {
    var latitude: Double
    var longitude: Double
    var altitude: Double
    static func == (left: Point, right: Point) -> Bool {
        return left.latitude == right.latitude && left.longitude == right.longitude
    }
    init(latitude: Double, longitude: Double, altitude: Double) {
        self.latitude = latitude
        self.longitude = longitude
        self.altitude = altitude
    }
}
