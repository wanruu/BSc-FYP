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
    @State var plans: [[Route]]
    
    // height
    @State var lastHeight = smallH
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
                PlanTextView(locations: locations, plan: plans[0])
                    .padding()
                    .frame(width: SCWidth, height: height, alignment: .center)
                    .background(Color.white)
            }
        }.gesture(drag)
    }
}

struct PlanTextView: View {
    @State var locations: [Location]
    @State var plan: [Route]
    
    var body: some View {
        var totalTime = 0.0 // seconds
        var totalDist = 0.0 // meters
        var maxHeight = -1.0
        var minHeight = 99999.0
        for route in plan {
            if route.type == 0 {
                totalTime += route.dist / footSpeed
            } else if route.type == 1 {
                totalTime += route.dist / busSpeed
            }
            totalDist += route.dist
            // TODO: 可能重复比较
            var altitude = route.points[0].altitude
            if altitude > maxHeight {
                maxHeight = altitude
            } else if altitude < minHeight {
                minHeight = altitude
            }
            altitude = route.points[route.points.count - 1].altitude
            if altitude > maxHeight {
                maxHeight = altitude
            } else if altitude < minHeight {
                minHeight = altitude
            }
        }
        return GeometryReader { geometry in
            VStack(alignment: .leading, spacing: 20) {
                // time & distance
                HStack {
                    Text(String(Int(totalTime))).font(.title2).bold()
                    Text("min").font(.title2)
                    Text("(\(Int(totalDist)) m)").font(.title3).foregroundColor(Color.gray)
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
                        for i in 0..<plan.count {
                            let p1 = CGPoint(x: Double(geometry.size.width * 0.9) / totalDist * dist + Double(geometry.size.width * 0.05), y: Double(geometry.size.width) / 8 / (maxHeight - minHeight) * (maxHeight - plan[i].points[0].altitude))
                            dist += plan[i].dist
                            let p2 = CGPoint(x: Double(geometry.size.width * 0.9) / totalDist * dist + Double(geometry.size.width * 0.05), y: Double(geometry.size.width) / 8 / (maxHeight - minHeight) * (maxHeight - plan[i].points.last!.altitude))
                            if i == 0 {
                                path.move(to: p1)
                                path.addLine(to: p2)
                            } else {
                                path.addLine(to: p1)
                                path.addLine(to: p2)
                            }
                        }
                    }.stroke(CUPurple, style: StrokeStyle(lineWidth: 4, lineJoin: .round))
                    Path { path in
                        path.move(to: CGPoint(x: geometry.size.width * 0.05, y: geometry.size.width / 6))
                        var dist = 0.0
                        for route in plan {
                            let p1 = CGPoint(x: Double(geometry.size.width * 0.9) / totalDist * dist + Double(geometry.size.width * 0.05), y: Double(geometry.size.width) / 8 / (maxHeight - minHeight) * (maxHeight - route.points.first!.altitude))
                            dist += route.dist
                            let p2 = CGPoint(x: Double(geometry.size.width * 0.9) / totalDist * dist + Double(geometry.size.width * 0.05), y: Double(geometry.size.width) / 8 / (maxHeight - minHeight) * (maxHeight - route.points.last!.altitude))
                            path.addLine(to: p1)
                            path.addLine(to: p2)
                        }
                        path.addLine(to: CGPoint(x: geometry.size.width * 0.95, y: geometry.size.width / 6))
                    }.fill(CUPurple.opacity(0.5))
                    Image(systemName: "circlebadge")
                        .imageScale(.large)
                        .background(Color.white)
                        .cornerRadius(100)
                        .position(x: geometry.size.width * 0.05, y: geometry.size.width / 8 / CGFloat(maxHeight - minHeight) * CGFloat(maxHeight - plan.first!.points.first!.altitude))
                    Image(systemName: "smallcircle.fill.circle")
                        .background(Color.white)
                        .cornerRadius(100)
                        .position(x: geometry.size.width * 0.95, y: geometry.size.width / 8 / CGFloat(maxHeight - minHeight) * CGFloat(maxHeight - plan.last!.points.last!.altitude))
                }.frame(height: geometry.size.width / 8)
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
                    ForEach(plan.indices) { i in
                        let location = locations.filter({$0.id == plan[i].startId}).first!
                        HStack(spacing: 20) {
                            Image(systemName: "circlebadge").imageScale(.large)
                            VStack(alignment: .leading) {
                                Text(location.name_en)
                                Divider()
                            }
                        }
                        HStack(spacing: 20) {
                            if plan[i].type == 0 {
                                Image(systemName: "figure.walk")
                                VStack(alignment: .leading) {
                                    Text("Walk for \(Int(plan[i].dist/footSpeed)) min (\(Int(plan[i].dist)) m)")
                                    Divider()
                                }
                            } else if plan[i].type == 1 {
                                Image(systemName: "bus")
                                // TODO: bus info
                                VStack(alignment: .leading) {
                                    Text("Take bus for \(Int(plan[i].dist/busSpeed)) min (\(Int(plan[i].dist)) m)")
                                    Divider()
                                }
                            }
                        }
                        
                        if i == plan.count - 1 {
                            let end = locations.filter({$0.id == plan[i].endId}).first!
                            HStack(spacing: 20) {
                                Image(systemName: "smallcircle.fill.circle")
                                VStack(alignment: .leading) {
                                    Text(end.name_en)
                                    Divider()
                                }
                            }
                        }
                        
                        
                        
                    }
                }
                
            }
        }
    }
}

struct RoundedCorners: View {
    var color: Color = .blue
    var tl: CGFloat = 0.0
    var tr: CGFloat = 0.0
    var bl: CGFloat = 0.0
    var br: CGFloat = 0.0
 
    var body: some View {
        GeometryReader { geometry in
            Path { path in
 
                let w = geometry.size.width
                let h = geometry.size.height
 
                // Make sure we do not exceed the size of the rectangle
                let tr = min(min(self.tr, h/2), w/2)
                let tl = min(min(self.tl, h/2), w/2)
                let bl = min(min(self.bl, h/2), w/2)
                let br = min(min(self.br, h/2), w/2)
 
                path.move(to: CGPoint(x: w / 2.0, y: 0))
                path.addLine(to: CGPoint(x: w - tr, y: 0))
                path.addArc(center: CGPoint(x: w - tr, y: tr), radius: tr, startAngle: Angle(degrees: -90), endAngle: Angle(degrees: 0), clockwise: false)
                path.addLine(to: CGPoint(x: w, y: h - br))
                path.addArc(center: CGPoint(x: w - br, y: h - br), radius: br, startAngle: Angle(degrees: 0), endAngle: Angle(degrees: 90), clockwise: false)
                path.addLine(to: CGPoint(x: bl, y: h))
                path.addArc(center: CGPoint(x: bl, y: h - bl), radius: bl, startAngle: Angle(degrees: 90), endAngle: Angle(degrees: 180), clockwise: false)
                path.addLine(to: CGPoint(x: 0, y: tl))
                path.addArc(center: CGPoint(x: tl, y: tl), radius: tl, startAngle: Angle(degrees: 180), endAngle: Angle(degrees: 270), clockwise: false)
            }
            .fill(self.color)
        }
    }
}
