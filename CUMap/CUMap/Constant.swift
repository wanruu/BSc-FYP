//
//  Constant.swift
//  CUMap
//
//  Created by wanruuu on 27/11/2020.
//

import Foundation
import SwiftUI

// let server = "http://10.13.66.145:8000" /* lulu CUHK1x */
// let server = "http://10.13.115.254:8000" /* CUHK1x */
// let server = "http://10.6.32.127:8000" /* CUHK */
// let server = "http://169.254.161.175:8000" /* laptop */
let server = "http://42.194.159.158:8000" /* tencent server */

/* screen info */
let SCWidth = UIScreen.main.bounds.width
let SCHeight = UIScreen.main.bounds.height

/* center */
let centerX = SCWidth/2
let centerY = SCHeight/2

let centerLa = 22.419915 // +: down
let centerLg = 114.20774 // +: left

/* zoom in/out limit */
let initialZoom: CGFloat = 0.3
let maxZoomIn: CGFloat = 0.8
let minZoomOut: CGFloat = 0.2

/* map size: minZoomOut */
let mapWidth = 620.0
let mapHeight = 820.0

/* 1 degree of latitude & longitude: how many meters in real world? */
let laScale = 111000.0
let lgScale = 85390.0

