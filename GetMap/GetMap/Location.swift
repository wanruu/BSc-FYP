/* MARK: Data Structure (Location) */

/* Created to save storage, in replace of CLLocation */

import Foundation

struct Coordinate {
    var latitude: Double
    var longitude: Double
}

struct Location {
    var coordinate: Coordinate
    var altitude: Double
}
