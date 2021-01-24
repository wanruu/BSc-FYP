import Foundation

struct Bus: Codable, Identifiable {
    var id: String
    var name_en: String
    var serviceHour: String
    var serviceDay: Int
    var stops: [String]
    var departTime: [Int]
}
