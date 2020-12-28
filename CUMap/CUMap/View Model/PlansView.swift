import Foundation
import SwiftUI

/*
    􀌇: line.horizontal.3
    􀧙: circlebadge
    􀍷: smallcircle.fill.circle
    􀢙: record.circle
    􀁟: exclamationmark.circle.fill
 */

struct PlansTextView: View {
    @State var locations: [Location]
    @State var plans: [[Route]]
    @State var mode: TransMode
    @State var lastHeight: CGFloat = SCHeight / 10
    @State var height: CGFloat = SCHeight / 10
    
    var drag: some Gesture {
        DragGesture()
            .onChanged { value in
                if lastHeight + value.startLocation.y - value.location.y < 0 {
                    height = 0
                } else {
                    height = lastHeight + value.startLocation.y - value.location.y
                }
            }
            .onEnded { _ in
                withAnimation() {
                    if height > SCHeight / 10 * 8.8 {
                        height = SCHeight / 10 * 8.8
                    } else if height < SCHeight / 10 {
                        height = SCHeight / 10
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
                .background(Color.white)
            
            if plans.count == 0 {
                Text("No results").font(.title2)
                .padding()
                .frame(width: SCWidth, alignment: .center)
                .background(Color.white)
            } else {
                // TODO: display more plans
                PlanTextView(locations: locations, plan: plans[0], mode: mode)
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
    @State var mode: TransMode
    
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
            VStack(alignment: .leading) {
                // time & distance
                HStack {
                    Text(String(Int(totalTime))).font(.title2).bold()
                    Text("min").font(.title2)
                    Text("(\(Int(totalDist)) m)").font(.title3).foregroundColor(Color.gray)
                }
                Divider()
                // changing height
                HStack {
                    // TODO: changing height count
                }
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
                }.frame(height: geometry.size.width / 8).padding(.vertical)
                Divider()
                
                // Alert
                HStack {
                    Image(systemName: "exclamationmark.circle.fill")
                        .imageScale(.large)
                        .foregroundColor(CUYellow)
                    Text("The estimated time to arrive may not be accurate.")
                }
                Divider()
                
                // Indication
                ForEach(plan.indices) { i in
                    if i == 0 {
                        let start = locations.filter({$0.id == plan[i].startId}).first!
                        HStack {
                            Image(systemName: "circlebadge").imageScale(.large)
                            Text(start.name_en)
                        }
                    }
                    let location = locations.filter({$0.id == plan[i].endId}).first!
                    HStack {
                        Image(systemName: "smallcircle.fill.circle")
                        Text(location.name_en)
                    }
                    
                }
            }
        }
    }
}
