/* MARK: Data Structure (Offset) */

/* Created to fix the bug of zoom in/out function */

import Foundation
import SwiftUI

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
