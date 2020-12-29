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
       small                  medium               large
 ------------------    ------------------    -----------------
 |     Search     |    |                |    -----------------
 |                |    |                |    |      􀌇       |
 ------------------    |       Map      |    |               |
 |       􀌇       |    |                |    |               |
 |                |    |                |    |               |
 |                |    ------------------    |               |
 |       Map      |    |       􀌇       |    |SCHeight * 0.88|
 |                |    |                |    |               |
 |                |    |  SCHeight*0.4  |    |               |
 |                |    |                |    |               |
 ------------------    |                |    |               |
 |  SCHeight*0.1  |    |                |    |               |
 ------------------    ------------------    -----------------
 */

let smallH = SCHeight / 10
let mediumH = SCHeight / 10 * 4
let largeH = SCHeight / 10 * 8.8

struct PlansView: View {
    @State var locations: [Location]
    @Binding var plans: [Plan]
    
    // height
    @Binding var lastHeight: CGFloat
    @Binding var height: CGFloat

    var body: some View {
        if plans.count == 0 {
            NoPlanView(lastHeight: $lastHeight, height: $height)
        } else {
            // TODO: display more plans
            PlanView(locations: locations, plan: $plans[0], lastHeight: $lastHeight, height: $height)
        }
    }
}

struct NoPlanView: View {
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
        ZStack {
            // blank
            Rectangle()
                .frame(height: smallH, alignment: .center)
                .foregroundColor(.white)
                .offset(y: SCHeight * 0.5)
            VStack(spacing: 0) {
                Spacer()
                if lastHeight != 0 {
                    Image(systemName: "line.horizontal.3")
                        .foregroundColor(Color.gray)
                        .padding()
                        .frame(width: SCWidth)
                        .background(RoundedCorners(color: .white, tl: 30, tr: 30, bl: 0, br: 0))
                        .clipped()
                        .shadow(color: Color.gray.opacity(0.3), radius: 2, x: 0, y: -2)
                    Text("No results").font(.title2)
                        .frame(width: SCWidth, height: height, alignment: .center)
                        .background(Color.white)
                }
            }
        }.gesture(drag)
    }
}

struct PlanView: View {
    @State var locations: [Location]
    @Binding var plan: Plan
    
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
        ZStack {
            // blank
            Rectangle()
                .frame(height: smallH, alignment: .center)
                .foregroundColor(.white)
                .offset(y: SCHeight * 0.5)
            VStack(spacing: 0) {
                Spacer()
                Image(systemName: "line.horizontal.3")
                    .foregroundColor(Color.gray)
                    .padding()
                    .frame(width: SCWidth)
                    .background(RoundedCorners(color: .white, tl: 30, tr: 30, bl: 0, br: 0))
                    .clipped()
                    .shadow(color: Color.gray.opacity(0.3), radius: 2, x: 0, y: -2)
                
                // content
                VStack(alignment: .leading, spacing: 0) {
                    // time & distance
                    HStack {
                        Text("\(Int(plan.time/60))").font(.title2).bold()
                        Text("min").font(.title2)
                        Text("(\(Int(plan.dist)) m)").font(.title3).foregroundColor(Color.gray)
                    }.padding(.horizontal).padding(.bottom)
                    Divider()
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            // chart
                            HeightChart(plan: $plan, width: SCWidth * 0.9, height: SCWidth * 0.25)
                                .padding(.vertical)
                            Divider()
                        }
                        VStack(alignment: .leading, spacing: 0) {
                            // Alert
                            HStack(spacing: 20) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundColor(CUYellow)
                                Text("The estimated time to arrive may not be accurate.")
                            }.padding()
                            Divider()
                            // steps
                            Instructions(locations: locations, plan: $plan)
                            Divider()
                        }
                    }
                }
                .frame(width: SCWidth, height: height, alignment: .center)
                .background(Color.white)
            }
        }.gesture(drag)
    }
}

/*
 |<---- width ----->|
 
 ---------------------   -
 |  􀄨 ?m     􀄩 ?m   |   | h1
 ---------------------   -
 |              |    |   | h2
 |              |    |   |
 |--------------|    |   -
 |              |    |   | h3
 ---------------------   -
 
 |<---- w1 ---->| w2 |
 
 w1 = width * 0.85
 w2 = width * 0.15
 h1 = height * 0.2
 h2 = height * 0.6
 h3 = height * 0.2

 */
struct HeightChart: View {
    @Binding var plan: Plan
    @State var width: CGFloat
    @State var height: CGFloat
    
    var body: some View {
        let w1 = width * 0.85
        let w2 = width * 0.15
        let h1 = height * 0.2
        let h2 = height * 0.6
        // let h3 = height * 0.2
        
        // find max, min altitude
        var maxHeight = -99999.0
        var minHeight = 99999.0
        for route in plan.routes {
            for point in route.points {
                if point.altitude > maxHeight {
                    maxHeight = point.altitude
                } else if point.altitude < minHeight {
                    minHeight = point.altitude
                }
            }
        }
        // calculate for drawing chart
        var up = 0.0
        var down = 0.0
        var lastAltitude = 0.0
        var dist = 0.0
        var lastDist = 0.0
        var chartPoints: [(Double, Double)] = [] // (distance, altitude)
        chartPoints.append((0, plan.routes[0].points[0].altitude))
        for route in plan.routes {
            for i in 0..<route.points.count {
                if i == 0 { continue }
                dist += distance(start: route.points[i-1], end: route.points[i])
                if dist - lastDist < 10 { continue }
                chartPoints.append((dist, route.points[i].altitude))
                lastDist = dist
                
                let diff = route.points[i].altitude - lastAltitude
                if diff > 0 {
                    up += diff
                } else {
                    down -= diff
                }
                lastAltitude = route.points[i].altitude
            }
        }
        chartPoints.append((dist, plan.routes.last!.points.last!.altitude))
        
        return ZStack {
            HStack {
                Image(systemName: "arrow.up").imageScale(.small)
                Text("\(Int(up)) m").font(.footnote).padding(.trailing)
                Image(systemName: "arrow.down").imageScale(.small).padding(.leading)
                Text("\(Int(down)) m").font(.footnote)
            }.offset(y: -height / 2 + h1 / 2)
            
            Path { path in
                path.move(to: CGPoint(x: 0, y: Double(h2) / (maxHeight - minHeight) * (maxHeight - plan.routes[0].points[0].altitude) + Double(h1)))
                for (x, y) in chartPoints {
                    path.addLine(to: CGPoint(x: Double(w1) / dist * x, y: Double(h2) / (maxHeight - minHeight) * (maxHeight - y) + Double(h1)))
                }
            }.stroke(CUPurple, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
            
            Path { path in
                path.move(to: CGPoint(x: 0, y: height))
                for (x, y) in chartPoints {
                    path.addLine(to: CGPoint(x: Double(w1) / dist * x, y: Double(h2) / (maxHeight - minHeight) * (maxHeight - y) + Double(h1)))
                }
                path.addLine(to: CGPoint(x: w1, y: height))
            }.fill(CUPurple.opacity(0.5))
            
            Image(systemName: "circlebadge")
                .imageScale(.large)
                .background(Color.white)
                .cornerRadius(100)
                .position(x: 0, y: h2 / CGFloat(maxHeight - minHeight) * CGFloat(maxHeight - plan.routes.first!.points.first!.altitude) + h1)
            
            Image(systemName: "smallcircle.fill.circle")
                .background(Color.white)
                .cornerRadius(100)
                .position(x: w1, y: h2 / CGFloat(maxHeight - minHeight) * CGFloat(maxHeight - plan.routes.last!.points.last!.altitude) + h1)
            
            
            Text("\(Int(plan.routes.first!.points.first!.altitude))m")
                .font(.footnote)
                .position(x: w1 + w2 / 2, y: h2 / CGFloat(maxHeight - minHeight) * CGFloat(maxHeight - plan.routes.first!.points.first!.altitude) + h1)
            Text("\(Int(plan.routes.last!.points.last!.altitude))m")
                .font(.footnote)
                .position(x: w1 + w2 / 2, y: h2 / CGFloat(maxHeight - minHeight) * CGFloat(maxHeight - plan.routes.last!.points.last!.altitude) + h1)
        }.frame(width: width, height: height)
    }
}

struct Instructions: View {
    @State var locations: [Location]
    @Binding var plan: Plan
    
    var body: some View {
        ZStack {
            // timeline sign
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 20) {
                    Divider().frame(width: 20)
                    Spacer()
                }.padding()
            }
            VStack(alignment: .leading, spacing: 0) {
                ForEach(plan.routes) { route in
                    if route == plan.routes.first! { // first route
                        let startLoc = locations.filter({$0.id == route.startId}).first!
                        HStack(spacing: 20) {
                            Image(systemName: "circlebadge").imageScale(.large).frame(width: 20)
                            Text(startLoc.name_en).font(.title3)
                            Spacer()
                        }.padding()
                    }
                    
                    if route.type == 0 {
                        HStack(spacing: 20) {
                            Image(systemName: "figure.walk").frame(width: 20)
                            Text("Walk for \(Int(route.dist/footSpeed/60)) min (\(Int(route.dist)) m)")
                            Spacer()
                        }.padding()
                    } else if route.type == 1 {
                        HStack(spacing: 20) {
                            Image(systemName: "bus").frame(width: 20)
                            // TODO: bus info
                            Text("Take bus for \(Int(route.dist/busSpeed/60)) min (\(Int(route.dist)) m)")
                            Spacer()
                        }.padding()
                    }
                    
                    let loc = locations.filter({$0.id == route.endId}).first!
                    HStack(spacing: 20) {
                        if route == plan.routes.last! { // last route
                            Image(systemName: "smallcircle.fill.circle")
                        } else if route.type == 0 {
                            Image(systemName: "building.2")
                        } else {
                            Image(systemName: "bus")
                        }
                        Text(loc.name_en).font(.title3)
                        Spacer()
                    }.padding()
                }
            }
        }
    }
}
