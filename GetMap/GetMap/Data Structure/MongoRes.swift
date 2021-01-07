import Foundation

struct DeleteResult: Codable {
    var n: Int
    var ok: Int
    var deletedCount: Int
}

struct PutResult: Codable {
    var n: Int
    var nModified: Int
    var ok: Int
}
