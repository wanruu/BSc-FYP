import Foundation

struct Bus: Codable, Identifiable {
    var id: String
    var name_en: String
    var name_ch: String
    var serviceHour: String
    var serviceDay: Int
    var stops: [String]
    var departTime: [Int]
    var special: [BusRule]
}

struct BusRule {
    var departTime: Int
    var busStop: String
    var stop: Bool
}
extension BusRule: Codable, Identifiable {
    public var id: String {
        "\(departTime)-\(busStop)-\(stop)"
    }
}
