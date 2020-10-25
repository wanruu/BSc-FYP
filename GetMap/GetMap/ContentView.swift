//
//  ContentView.swift
//  GetMap
//
//  Created by wanruuu on 24/10/2020.
//

import SwiftUI
import Foundation

/* screen info */
let SCWidth = UIScreen.main.bounds.width
let SCHeight = UIScreen.main.bounds.height

/* center */
let centerX = SCWidth/2
let centerY = SCHeight/2

struct ContentView: View {
    /* location getter */
    @ObservedObject var locationView = LocationGetterModel()
    /* panned offset */
    @State var lastOffset: CGPoint = CGPoint(x: 0, y: 0)
    @State var offset: CGPoint = CGPoint(x: 0, y: 0)
    /* for updating radius of user location point: animation */
    let timer = Timer.publish(every: 0.08, on: .main, in: .common).autoconnect()
    @State var animationRadius: CGFloat = 8
    @State var up: Bool = true // animationRadius is becoming larger or not
    
    var body: some View {
        /* user location point: at the center by default; panned with offset */
        let center = CGPoint(x: centerX + offset.x, y: centerY + offset.y)
        /* render */
        return ZStack(alignment: .topLeading) {
            GestureControlLayer { pan in
                if(pan.moving) {
                    offset.x = lastOffset.x + pan.offset.x
                    offset.y = lastOffset.y + pan.offset.y
                } else {
                    lastOffset = offset
                }
            }.background(Color.white)
            
            Path { path in
                /* draw paths of point list */
                for point in locationView.paths {
                    /* 1m = 2 (of screen) = 1/111000(latitude) = 1/85390(longitude) */
                    let x = centerX + CGFloat((point.longitude - locationView.longitude)*85390*2) + offset.x
                    let y = centerY + CGFloat((locationView.latitude - point.latitude)*111000*2) + offset.y
                    if(point == locationView.paths[0]) {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }.stroke(Color.black, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
            
            /* showing current location point */
            Animation(center: center, radius: animationRadius)
                .fill(Color.blue.opacity(0.2))
                .onReceive(timer) { _ in
                    if(up) { animationRadius += 0.4 }
                    else { animationRadius -= 0.4 }
                    if(animationRadius > 17) { up = false }
                    else if(animationRadius < 11) { up = true }
                }
            UserDirection(center: center, heading: locationView.heading)
                .fill(Color.blue)
            OuterPoint(center: center)
                .fill(Color.white)
            InnerPoint(center: center)
                .fill(Color.blue)
            /* ******************************* */
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
