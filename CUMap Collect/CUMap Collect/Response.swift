import Foundation

struct LocResponse: Codable {
    var _id: String
    var name_en: String
    var name_zh: String
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var type: Int
}

