import Foundation
import SwiftUI

/*
    􀌇: line.horizontal.3
    􀧙: circlebadge
    􀍷: smallcircle.fill.circle
    􀢙: record.circle
    􀁟: exclamationmark.circle.fill
 */

/*
       small                medium               large
 -----------------    -----------------    -----------------
 |    Search     |    |               |    -----------------
 |               |    |               |    |      􀌇       |
 -----------------    |      Map      |    |               |
 |               |    |               |    |               |
 |               |    |               |    |               |
 |               |    -----------------    |               |
 |      Map      |    |               |    |SCHeight/10*8.8|
 |               |    |               |    |               |
 |               |    | SCHeight/10*4 |    |               |
 |               |    |               |    |               |
 -----------------    |               |    |               |
 | SCHeight / 10 |    |               |    |               |
 -----------------    -----------------    -----------------
 */

let smallH = SCHeight / 10
let mediumH = SCHeight / 10 * 4
let largeH = SCHeight / 10 * 8.8

struct PlansTextView: View {
    @State var locations: [Location]
    @Binding var plans: [Plan]
    
    // height
    @Binding var lastHeight: CGFloat
    @Binding var height: CGFloat
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                if lastHeight + value.startLocation.y - value.location.y < 0 {
                    height = 0
                } else {
                    height = lastHeight + value.startLocation.y - value.location.y
                }
            }
            .onEnded { value in
                // whether scroll up or down
                let up = value.startLocation.y - value.location.y > 0
                withAnimation() {
                    if lastHeight == largeH { // large
                        if height > (mediumH + largeH) / 2 { // still large
                            height = up ? largeH : mediumH
                        } else {
                            height = height < (smallH + mediumH) / 2 ? smallH : mediumH
                        }
                    } else if lastHeight == smallH { // small
                        if height < (smallH + mediumH) / 2 { // still small
                            height = up ? mediumH : smallH
                        } else {
                            height = height > (mediumH + largeH) / 2 ? largeH : mediumH
                        }
                    } else { // medium
                        if height >= (smallH + mediumH) / 2 && height <= (mediumH + largeH) / 2 { // still medium
                            height = up ? largeH : smallH
                        }
                        height = height > (mediumH + largeH) / 2 ? largeH : smallH
                    }
                }
                lastHeight = height
            }
    }

    var body: some View {
        VStack(spacing: 0) {
            Spacer()
            Image(systemName: "line.horizontal.3")
                .foregroundColor(Color.gray)
                .padding(.top)
                .frame(width: SCWidth, alignment: .center)
                .background(RoundedCorners(color: .white, tl: 30, tr: 30, bl: 0, br: 0))
                .shadow(radius: 10)
            
            if plans.count == 0 {
                Text("No results").font(.title2)
                    .padding()
                    .frame(width: SCWidth, height: height, alignment: .center)
                    .background(Color.white)
            } else {
                // TODO: display more plans
                PlanTextView(locations: locations, plan: $plans[0])
                    .padding()
                    .frame(width: SCWidth, height: height, alignment: .center)
                    .background(Color.white)
            }
        }.gesture(drag)
    }
}

struct PlanTextView: View {
    @State var locations: [Location]
    @Binding var plan: Plan
    
    var body: some View {
        var maxHeight = -99999.0
        var minHeight = 99999.0
        for route in plan.routes {
            for point in route.points {
                let altitude = point.altitude
                if altitude > maxHeight {
                    maxHeight = altitude
                } else if altitude < minHeight {
                    minHeight = altitude
                }
            }
        }
        return GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 20) {
                // time & distance
                HStack {
                    Text(String(Int(plan.time / 60))).font(.title2).bold()
                    Text("min").font(.title2)
                    Text("(\(Int(plan.dist)) m)").font(.title3).foregroundColor(Color.gray)
                }
                Divider()
                // changing height
                //HStack {
                    // TODO: changing height count
                //}
                // height chart
                ZStack {
                    Path { path in
                        var dist = 0.0
                        for i in 0..<plan.routes.count {
                            let p1 = CGPoint(
                                x: Double(geometry.size.width * 0.9) / plan.dist * dist + Double(geometry.size.width * 0.05),
                                y: Double(geometry.size.width) / 8 / (maxHeight - minHeight) * (maxHeight - plan.routes[i].points[0].altitude))
                            dist += plan.routes[i].dist
                            let p2 = CGPoint(
                                x: Double(geometry.size.width * 0.9) / plan.dist * dist + Double(geometry.size.width * 0.05),
                                y: Double(geometry.size.width) / 8 / (maxHeight - minHeight) * (maxHeight - plan.routes[i].points.last!.altitude))
                            if i == 0 {
                                path.move(to: p1)
                            } else {
                                path.addLine(to: p1)
                            }
                            path.addLine(to: p2)
                        }
                    }.stroke(CUPurple, style: StrokeStyle(lineWidth: 4, lineJoin: .round))
                    Path { path in
                        path.move(to: CGPoint(x: geometry.size.width * 0.05, y: geometry.size.width / 5))
                        var dist = 0.0
                        for route in plan.routes {
                            let p1 = CGPoint(x: Double(geometry.size.width * 0.9) / plan.dist * dist + Double(geometry.size.width * 0.05), y: Double(geometry.size.width) / 8 / (maxHeight - minHeight) * (maxHeight - route.points.first!.altitude))
                            dist += route.dist
                            let p2 = CGPoint(x: Double(geometry.size.width * 0.9) / plan.dist * dist + Double(geometry.size.width * 0.05), y: Double(geometry.size.width) / 8 / (maxHeight - minHeight) * (maxHeight - route.points.last!.altitude))
                            path.addLine(to: p1)
                            path.addLine(to: p2)
                        }
                        path.addLine(to: CGPoint(x: geometry.size.width * 0.95, y: geometry.size.width / 5))
                    }.fill(CUPurple.opacity(0.5))
                    Image(systemName: "circlebadge")
                        .imageScale(.large)
                        .background(Color.white)
                        .cornerRadius(100)
                        .position(x: geometry.size.width * 0.05, y: geometry.size.width / 8 / CGFloat(maxHeight - minHeight) * CGFloat(maxHeight - plan.routes.first!.points.first!.altitude))
                    Image(systemName: "smallcircle.fill.circle")
                        .background(Color.white)
                        .cornerRadius(100)
                        .position(x: geometry.size.width * 0.95, y: geometry.size.width / 8 / CGFloat(maxHeight - minHeight) * CGFloat(maxHeight - plan.routes.last!.points.last!.altitude))
                }.frame(height: geometry.size.width / 5)
                Divider()
                
                // Alert
                HStack(spacing: 20) {
                    Image(systemName: "exclamationmark.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(CUYellow)
                    Text("The estimated time to arrive may not be accurate.")
                }
                Divider()
                
                // Indication
                VStack(alignment: .leading, spacing: 30) {
                    ForEach(plan.routes) { route in
                        let location = locations.filter({$0.id == route.startId}).first!
                        HStack(spacing: 20) {
                            Image(systemName: "circlebadge").imageScale(.large)
                            Text(location.name_en).font(.title3)
                        }
                        HStack(spacing: 20) {
                            if route.type == 0 {
                                Image(systemName: "figure.walk")
                                Text("Walk for \(Int(route.dist/footSpeed/60)) min (\(Int(route.dist)) m)")
                            } else if route.type == 1 {
                                Image(systemName: "bus")
                                // TODO: bus info
                                Text("Take bus for \(Int(route.dist/busSpeed/60)) min (\(Int(route.dist)) m)")
                            }
                        }
                        
                        if route == plan.routes.last! {
                            let end = locations.filter({$0.id == route.endId}).first!
                            HStack(spacing: 20) {
                                Image(systemName: "smallcircle.fill.circle")
                                Text(end.name_en).font(.title3)
                            }
                        }
                        
                        
                        
                    }
                }
                
            }
        }
    }
}
