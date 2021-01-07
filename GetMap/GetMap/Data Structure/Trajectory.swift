import Foundation

struct Trajectory {
    var _id: String
    var points: [Coor3D]
}

extension Trajectory: Codable, Identifiable {
    public var id: String {
        self._id
    }
}
