/* MARK: Data Structure (Location) */


import Foundation

struct Location: Codable {
    var name_en: String
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var type: Int
}
