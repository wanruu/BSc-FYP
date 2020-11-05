//
//  GlobalVariable.swift
//  GetMap
//
//  Created by wanruuu on 5/11/2020.
//

import Foundation
import SwiftUI

/* screen info */
let SCWidth = UIScreen.main.bounds.width
let SCHeight = UIScreen.main.bounds.height

/* center */
let centerX = SCWidth/2
let centerY = SCHeight/2 - 150

/* zoom in/out limit */
let maxZoomIn: CGFloat = 8.0
let minZoomOut: CGFloat = 0.1
