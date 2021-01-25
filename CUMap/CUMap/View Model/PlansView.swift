import Foundation
import SwiftUI

/*
    􀌇: line.horizontal.3
    􀧙: circlebadge
    􀍷: smallcircle.fill.circle
    􀢙: record.circle
    􀁟: exclamationmark.circle.fill

       small                  medium               large
 ------------------    ------------------    -----------------
 |     Search     |    |                |    -----------------
 |                |    |                |    |      􀌇       |
 ------------------    |      Map       |    |               |
 |                |    |                |    |               |
 |                |    |                |    |               |
 |                |    ------------------    |               |
 |       Map      |    |       􀌇       |    |               |
 |                |    |                |    |               |
 |                |    |                |    |               |
 |                |    |                |    |               |
 ------------------    |                |    |               |
 |       􀌇       |    |                |    |               |
 ------------------    ------------------    -----------------
 */

// height of plansView sheet
let smallH = UIScreen.main.bounds.height * 0.25
let mediumH = UIScreen.main.bounds.height * 0.55
let largeH = UIScreen.main.bounds.height * 0.9

struct PlansView: View {
    @Binding var plans: [Plan]
    @Binding var planIndex: Int
    
    // height
    @Binding var lastHeight: CGFloat
    @Binding var height: CGFloat
    
    var body: some View {
        if plans.isEmpty {
            NoPlanView(lastHeight: $lastHeight, height: $height)
        } else if planIndex >= 0 && planIndex < plans.count {
            PlanView(plans: $plans, planIndex: $planIndex, lastHeight: $lastHeight, height: $height)
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
                } else if lastHeight + value.startLocation.y - value.location.y > largeH {
                    height = largeH
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
        GeometryReader { geometry in
            VStack {
                Spacer()
                VStack {
                    Image(systemName: "line.horizontal.3")
                        .foregroundColor(Color.gray)
                        .padding()
                    Text("No results").font(.title2)
                }
                .frame(width: geometry.size.width, height: largeH, alignment: .top)
                .background(RoundedCorners(color: .white, tl: 15, tr: 15, bl: 0, br: 0))
                .clipped()
                .shadow(radius: 4)
            }
            .ignoresSafeArea(.all, edges: .bottom)
            .offset(y: largeH - height)
            .gesture(drag)
        }
    }
}

struct PlanView: View {
    @Binding var plans: [Plan]
    @Binding var planIndex: Int
    
    @Binding var lastHeight: CGFloat
    @Binding var height: CGFloat
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                if lastHeight + value.startLocation.y - value.location.y < 0 {
                    height = 0
                } else if lastHeight + value.startLocation.y - value.location.y > largeH {
                    height = largeH
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
        GeometryReader { geometry in
            VStack {
                Spacer()
                VStack(alignment: .leading, spacing: 0) {
                    // drag icon
                    HStack {
                        Button(action: { planIndex -= 1 }) {
                            Image(systemName: "arrow.left")
                        }.disabled(planIndex == 0)
                        Spacer()
                        Image(systemName: "line.horizontal.3").foregroundColor(Color.gray)
                        Spacer()
                        Button(action: { planIndex += 1 }) {
                            Image(systemName: "arrow.right")
                        }.disabled(planIndex == plans.count - 1)
                        
                    }.padding()
                    
                    // title
                    HStack {
                        Text("\(Int(plans[planIndex].time/60))").font(.title2).bold()
                        Text("min").font(.title2)
                        Text("(\(Int(plans[planIndex].dist)) m)").font(.title3).foregroundColor(Color.gray)
                    }.padding(.horizontal).padding(.bottom)
                    Divider()
                    
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 0) {
                            // chart
                            HeightChart(plan: $plans[planIndex])
                                .frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.25, alignment: .center)
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
                            Instructions(plan: $plans[planIndex])
                            Divider()
                        }
                    }.gesture(DragGesture())
                }
                .frame(width: geometry.size.width, height: largeH, alignment: .top)
                .background(RoundedCorners(color: .white, tl: 15, tr: 15, bl: 0, br: 0))
                .clipped()
                .shadow(radius: 4)
            }
            .ignoresSafeArea(.all, edges: .bottom)
            .offset(y: largeH - height)
            .gesture(drag)
        }
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
    
    var body: some View {
        // find max, min altitude
        var maxHeight = -INF
        var minHeight = INF
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
        
        return GeometryReader { geometry in
            let width = geometry.size.width * 0.9
            let height = geometry.size.width * 0.25
            
            let w1 = geometry.size.width * 0.9 * 0.9
            let w2 = geometry.size.width * 0.9 * 0.1
            let h1 = geometry.size.width * 0.25 * 0.2
            let h2 = geometry.size.width * 0.25 * 0.6
            // let h3 = geometry.size.height * 0.2
            ZStack {
                HStack {
                    Image(systemName: "arrow.up").imageScale(.small)
                    Text("\(Int(up)) m").font(.footnote).padding(.trailing)
                    Image(systemName: "arrow.down").imageScale(.small).padding(.leading)
                    Text("\(Int(down)) m").font(.footnote)
                }.offset(y: -height / 2 + h1 / 2)
                
                Text("\(Int(plan.routes.first!.points.first!.altitude))m")
                    .font(.footnote)
                    .position(x: w1 + w2, y: h2 / CGFloat(maxHeight - minHeight) * CGFloat(maxHeight - plan.routes.first!.points.first!.altitude) + h1)
                
                Text("\(Int(plan.routes.last!.points.last!.altitude))m")
                    .font(.footnote)
                    .position(x: w1 + w2, y: h2 / CGFloat(maxHeight - minHeight) * CGFloat(maxHeight - plan.routes.last!.points.last!.altitude) + h1)
                
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
            }
            .frame(width: width, height: height, alignment: .center)
        }
    }
}

struct Instructions: View {
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
                        HStack(spacing: 20) {
                            Image(systemName: "circlebadge").imageScale(.large).frame(width: 20)
                            Text(plan.startLoc.name_en).font(.title3)
                            Spacer()
                        }.padding()
                    }
                    
                    if route.type == 0 {
                        HStack(spacing: 20) {
                            Image(systemName: "figure.walk").frame(width: 20)
                            Text("Walk for \(Int(route.dist/footSpeed/60)) min (\(Int(route.dist)) m)")
                            Spacer()
                        }.padding()
                    } else {
                        HStack(spacing: 20) {
                            Image(systemName: "bus").frame(width: 20)
                            // TODO: bus info
                            Text("Take bus for \(Int(route.dist/busSpeed/60)) min (\(Int(route.dist)) m)")
                            Spacer()
                        }.padding()
                    }

                    HStack(spacing: 20) {
                        if route == plan.routes.last! { // last route
                            Image(systemName: "smallcircle.fill.circle")
                        } else if route.endLoc.type == 0 {
                            Image(systemName: "building.2")
                        } else {
                            Image(systemName: "bus")
                        }
                        Text(route.endLoc.name_en).font(.title3)
                        Spacer()
                    }.padding()
                }
            }
        }
    }
}
