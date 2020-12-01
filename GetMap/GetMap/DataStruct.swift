/* MARK: Data Structure (Location) */

import Foundation
import SwiftUI

struct Location: Codable {
    var name_en: String
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var type: Int
}

extension Location: Identifiable {
    public var id: String {
        self.name_en
    }
    
}

struct Coor3D: Codable {
    var latitude: Double
    var longitude: Double
    var altitude: Double
}

struct LineSeg {
    var start: Coor3D
    var end: Coor3D
    var clusterId: Int
}
extension LineSeg: Identifiable {
    public var id: String {
        "\(self.start.latitude)\(self.end.latitude)"
    }
}

/* MARK: Data Structure (Offset) */

/* Created to fix the bug of zoom in/out function */

struct Offset {
    var x: CGFloat
    var y: CGFloat
}

extension Offset {
    static func * (offset: Offset, para: CGFloat) -> Offset {
        return Offset(x: offset.x * para, y: offset.y * para)
    }
    static func / (offset: Offset, para: CGFloat) -> Offset {
        return Offset(x: offset.x / para, y: offset.y / para)
    }
}

