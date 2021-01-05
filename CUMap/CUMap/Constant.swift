//
//  Constant.swift
//  CUMap
//
//  Created by wanruuu on 27/11/2020.
//

import Foundation
import SwiftUI

// let server = "http://10.13.66.145:8000" /* lulu CUHK1x */
let server = "http://10.13.16.219:8000" /* CUHK1x */
// let server = "http://10.6.32.127:8000" /* CUHK */
// let server = "http://169.254.161.175:8000" /* laptop */
// let server = "http://42.194.159.158:8000" /* tencent server */

// center
// let centerX = SCWidth/2
// let centerY = SCHeight/2

let centerLa = 22.419915 // +: down
let centerLg = 114.20774 // +: left

// zoom in/out limit
let initialZoom: CGFloat = 0.3
let maxZoomIn: CGFloat = 0.8
let minZoomOut: CGFloat = 0.2

// map size: minZoomOut
let mapWidth = 620.0
let mapHeight = 820.0

// 1 degree of latitude & longitude: how many meters in real world?
let laScale = 111000.0
let lgScale = 85390.0

// CUHK Color
let CUPurple = Color(red: 117/255, green: 15/255, blue: 109/255)
let CUYellow = Color(red: 221/255, green: 163/255, blue: 0)
let CUPaleYellow = Color(red: 244/255, green: 223/255, blue: 176/255)

// Speed: m/s
let busSpeed = 2.0
let footSpeed = 0.9
