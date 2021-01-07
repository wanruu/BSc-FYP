import Foundation

struct LineSeg {
    var start: Coor3D
    var end: Coor3D
    var clusterId: Int
}

extension LineSeg: Identifiable {
    public var id: String {
        "\(self.start.id)-\(self.end.id)"
    }
}
