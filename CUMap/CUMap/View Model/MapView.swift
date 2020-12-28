/*
    Map View.
    - User Current Location
    - Search Result: plans
 */

import Foundation
import SwiftUI

struct MapView: View {
    @State var plans: [[Route]]
    @ObservedObject var locationGetter: LocationGetterModel
    
    /* gesture */
    @State var lastOffset = Offset(x: 0, y: 0)
    @State var offset = Offset(x: 0, y: 0)
    @State var lastScale = initialZoom
    @State var scale = initialZoom
    var gesture: some Gesture {
        SimultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    var tmpScale = lastScale * value.magnitude
                    if(tmpScale < minZoomOut) {
                        tmpScale = minZoomOut
                    } else if(tmpScale > maxZoomIn) {
                        tmpScale = maxZoomIn
                    }
                    scale = tmpScale
                    offset = lastOffset * tmpScale / lastScale
                }
                .onEnded { _ in
                    lastScale = scale
                    lastOffset = offset
                },
            DragGesture()
                .onChanged{ value in
                    offset.x = lastOffset.x + value.location.x - value.startLocation.x
                    offset.y = lastOffset.y + value.location.y - value.startLocation.y
                }
                .onEnded{ _ in
                    lastOffset = offset
                }
        )
    }
    
    var body: some View {
        ZStack {
            Image("cuhk-campus-map")
                .resizable()
                .frame(width: 3200 * scale, height: 3200 * 25 / 20 * scale, alignment: .center)
                .position(x: centerX + offset.x, y: centerY + offset.y)
                
            PlansView(plans: plans, offset: $offset, scale: $scale)
            
            UserPoint(locationGetter: locationGetter, offset: $offset, scale: $scale)
        }
        .contentShape(Rectangle())
        .gesture(gesture)
    }
}

struct PlansView: View {
    @State var plans: [[Route]]
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    var body: some View {
        ForEach(plans.indices) { i in
            let plan = plans[i]
            ForEach(plan) { route in
                // Display a route
                Path { path in
                    for j in 0..<route.points.count {
                        let point = CGPoint(
                            x: centerX + CGFloat((route.points[j].longitude - centerLg)*lgScale*2) * scale + offset.x,
                            y: centerY + CGFloat((centerLa - route.points[j].latitude)*laScale*2) * scale + offset.y
                        )
                        if(j == 0) {
                            path.move(to: point)
                        } else {
                            path.addLine(to: point)
                        }
                    }
                }.stroke(route.type == 0 ? CUPurple : CUYellow, style: StrokeStyle(lineWidth: 5, lineJoin: .round))
            }
        }
    }
}
