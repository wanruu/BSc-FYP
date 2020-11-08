//
//  Offset.swift
//  GetMap
//
//  Created by wanruuu on 9/11/2020.
//

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
