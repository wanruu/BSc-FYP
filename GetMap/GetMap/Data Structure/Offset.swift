// Created to fix the bug of zoom in/out function

import Foundation
import SwiftUI

struct Offset {
    var x: CGFloat
    var y: CGFloat
}

extension Offset: Equatable {
    static func * (offset: Offset, para: CGFloat) -> Offset {
        return Offset(x: offset.x * para, y: offset.y * para)
    }
    static func / (offset: Offset, para: CGFloat) -> Offset {
        return Offset(x: offset.x / para, y: offset.y / para)
    }
    
    // Equatable
    static func == (o1: Offset, o2: Offset) -> Bool {
        return o1.x == o2.x && o1.y == o2.y
    }
}

