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

let BUS_IDS: [String?] = ["1A", "1B", "2", "3", "4", "5", "6A", "6B", "7", "8", "light", nil]
let BUS_COLORS: [String?: Color] = [
    nil: Color.black,
    "1A": Color(red: 227/255, green: 222/255, blue: 0),
    "1B": Color(red: 227/255, green: 222/255, blue: 0),
    "2": Color(red: 255/255, green: 102/255, blue: 204/255),
    "3": Color(red: 155/255, green: 187/255, blue: 89/255),
    "4": Color(red: 247/255, green: 150/255, blue: 70/255),
    "5": Color(red: 182/255, green: 221/255, blue: 232/255),
    "6A": Color(red: 118/255, green: 146/255, blue: 60/255),
    "6B": Color(red: 124/255, green: 168/255, blue: 222/255),
    "7": Color(red: 192/255, green: 192/255, blue: 192/255),
    "8": Color(red: 255/255, green: 192/255, blue: 67/255),
    "light": Color(red: 151/255, green: 81/255, blue: 150/255)
]
// Speed: m/s
let busSpeed = 3.0
let footSpeed = 0.9
