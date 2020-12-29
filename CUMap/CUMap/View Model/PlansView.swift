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
        VStack(spacing: 0) {
            Spacer()
            if height != 0 {
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
        .gesture(drag)
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
                    VStack {
                        // chart
                        HeightChart(plan: $plan, width: SCWidth * 0.9, height: SCWidth * 0.2)
                            .frame(height: SCWidth * 0.3)
                        Divider()
                    }
                    VStack(alignment: .leading) {
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
        }.gesture(drag)
    }
}

struct HeightChart: View {
    @Binding var plan: Plan
    @State var width: CGFloat
    @State var height: CGFloat
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
        return ZStack {
            Path { path in
                var dist = 0.0
                for i in 0..<plan.routes.count {
                    let p1 = CGPoint(
                        x: Double(width) / plan.dist * dist,
                        y: Double(height) * 0.75 / (maxHeight - minHeight) * (maxHeight - plan.routes[i].points.first!.altitude))
                    dist += plan.routes[i].dist
                    let p2 = CGPoint(
                        x: Double(width) / plan.dist * dist,
                        y: Double(height) * 0.75 / (maxHeight - minHeight) * (maxHeight - plan.routes[i].points.last!.altitude))
                    if i == 0 {
                        path.move(to: p1)
                    } else {
                        path.addLine(to: p1)
                    }
                    path.addLine(to: p2)
                }
            }.stroke(CUPurple, style: StrokeStyle(lineWidth: 4, lineJoin: .round))
            
            Path { path in
                path.move(to: CGPoint(x: 0, y: height))
                var dist = 0.0
                for route in plan.routes {
                    let p1 = CGPoint(
                        x: Double(width) / plan.dist * dist,
                        y: Double(height) * 0.75 / (maxHeight - minHeight) * (maxHeight - route.points.first!.altitude))
                    dist += route.dist
                    let p2 = CGPoint(
                        x: Double(width) / plan.dist * dist,
                        y: Double(height) * 0.75 / (maxHeight - minHeight) * (maxHeight - route.points.last!.altitude))
                    path.addLine(to: p1)
                    path.addLine(to: p2)
                }
                path.addLine(to: CGPoint(x: width, y: height))
            }.fill(CUPurple.opacity(0.5))
            
            Image(systemName: "circlebadge")
                .imageScale(.large)
                .background(Color.white)
                .cornerRadius(100)
                .position(
                    x: 0,
                    y: height * 0.75 / CGFloat(maxHeight - minHeight) * CGFloat(maxHeight - plan.routes.first!.points.first!.altitude))
            
            Image(systemName: "smallcircle.fill.circle")
                .background(Color.white)
                .cornerRadius(100)
                .position(
                    x: width,
                    y: height * 0.75 / CGFloat(maxHeight - minHeight) * CGFloat(maxHeight - plan.routes.last!.points.last!.altitude))
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
