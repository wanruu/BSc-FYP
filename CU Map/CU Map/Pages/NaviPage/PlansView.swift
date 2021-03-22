import SwiftUI

struct PlansOnFootView: View {
    @Binding var plansOnFoot: [Plan]
    @Binding var selectedPlan: Plan?
    
    var body: some View {
        if selectedPlan == nil {
            List {
                ForEach(plansOnFoot) { plan in
                    Button(action: {
                        selectedPlan = plan
                    }) {
                        Text(String(Int(plan.dist)) + " " + NSLocalizedString("m", comment: ""))
                    }
                }
            }
        } else {
            PlanView(selectedPlan: $selectedPlan)
        }
    }
}

struct PlansByBusView: View {
    @Binding var plansByBus: [Plan]
    @Binding var selectedPlan: Plan?
    @Binding var searchTime: Date
    
    var body: some View {
        if selectedPlan == nil {
            VStack {
                DatePicker("Depart at", selection: $searchTime).padding(.horizontal)
                List {
                    ForEach(plansByBus) { plan in
                        PlansByBusItemView(plan: plan, selectedPlan: $selectedPlan)
                    }
                }
            }
        } else {
            PlanView(selectedPlan: $selectedPlan)
        }
    }
    
    struct RouteToDisplayInPlan: Identifiable {
        var id = UUID()
        var bus: Bus?
        var time: Int // min
    }
    
    struct PlansByBusItemView: View {
        @State var plan: Plan
        @Binding var selectedPlan: Plan?
        
        var body: some View {
            var routes: [RouteToDisplayInPlan] = []
            for route in plan.routes {
                let thisBus = route.bus
                let thisTime = route.type == .byBus ? Int(route.dist / SPEED_BY_BUS / 60) : Int(route.dist / SPEED_ON_FOOT / 60)
                
                if let lastRoutes = routes.last { // has last item
                    let lastBus = lastRoutes.bus
                    let lastTime = lastRoutes.time
                    if let lastBus = lastBus { // lastBus != nil
                        if let thisBus = thisBus { // thisBus != nil
                            if lastBus.id == thisBus.id {
                                routes.removeLast()
                                routes.append(RouteToDisplayInPlan(bus: thisBus, time: lastTime + thisTime))
                            } else {
                                routes.append(RouteToDisplayInPlan(bus: thisBus, time: thisTime))
                            }
                        } else { // thisBus == nil
                            routes.append(RouteToDisplayInPlan(bus: thisBus, time: thisTime))
                        }
                    } else { // lastBus == nil
                        if let thisBus = thisBus { // thisBus != nil
                            routes.append(RouteToDisplayInPlan(bus: thisBus, time: thisTime))
                        } else { // thisBus == nil
                            routes.removeLast()
                            routes.append(RouteToDisplayInPlan(bus: thisBus, time: lastTime + thisTime))
                        }
                    }
                } else { // routes empty
                    routes.append(RouteToDisplayInPlan(bus: thisBus, time: thisTime))
                }
            }
            return
                Button(action: {
                    selectedPlan = plan
                }) {
                    HStack {
                        ForEach(routes) { route in
                            HStack(alignment: .bottom, spacing: 0) {
                                if let bus = route.bus { // by bus
                                    Text(bus.line)
                                        .font(.system(size: 18, weight: .bold, design: .rounded))
                                        .lineLimit(1)
                                        .minimumScaleFactor(0.2)
                                        .frame(width: 18)
                                        .foregroundColor(Color.white)
                                        .padding(6)
                                        .background(BUS_COLORS[bus.line])
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "figure.walk")
                                        .foregroundColor(Color.primary.opacity(0.8))
                                }
                                Text(String(route.time))
                                    .font(.footnote)
                                    .foregroundColor(Color.secondary)
                            }
                            if route.id != routes.last?.id {
                                Image(systemName: "chevron.right")
                            }
                        }
                        Spacer()
                        HStack {
                            Text("\(Int(plan.time)) mins")
                            Image(systemName: "chevron.right")
                        }
                    }
                }
        }
    }
}


struct PlanView: View {
    @Binding var selectedPlan: Plan?
    
    var body: some View {
        if let selectedPlan = selectedPlan {
            GeometryReader { geometry in
                VStack {
                    Button(action: {
                        self.selectedPlan = nil
                    }) {
                        Text("Back")
                    }
                    // title
                    HStack {
                        Text("\(Int(selectedPlan.time / 60))").font(.title2).bold()
                        Text("min").font(.title2)
                        Text("(\(Int(selectedPlan.dist)) m)").font(.title3).foregroundColor(Color.gray)
                        Spacer()
                    }.padding(.horizontal).padding(.bottom)
                    Divider()
                    
                    ScrollView(.vertical) {
                        VStack(spacing: 0) {
                            // chart
                            HeightChart(plan: selectedPlan)
                                .frame(width: geometry.size.width * 0.9, height: geometry.size.width * 0.25, alignment: .center)
                                .padding(.vertical)
                            Divider()

                            // Alert
                            HStack(spacing: 20) {
                                Image(systemName: "exclamationmark.circle.fill")
                                    .imageScale(.large)
                                    .foregroundColor(CU_YELLOW)
                                Text("The estimated time to arrive may not be accurate.")
                                Spacer()
                            }.padding()
                            Divider()
                            // steps
                            Instructions(plan: selectedPlan)
                            Divider()
                        }
                    }
                }
            }
        }
    }
}


struct HeightChart: View {
    @State var plan: Plan?
    
    var body: some View {
        // find max, min altitude
        var maxHeight: Double = -.infinity
        var minHeight: Double = .infinity
        for route in plan!.routes {
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
        chartPoints.append((0, plan!.routes[0].points[0].altitude))
        for route in plan!.routes {
            for i in 0..<route.points.count {
                if i == 0 { continue }
                dist += distance(from: route.points[i-1], to: route.points[i])
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
        chartPoints.append((dist, plan!.routes.last!.points.last!.altitude))
        
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
                
                Text("\(Int(plan!.routes.first!.points.first!.altitude))m")
                    .font(.footnote)
                    .position(x: w1 + w2, y: h2 / CGFloat(maxHeight - minHeight) * CGFloat(maxHeight - plan!.routes.first!.points.first!.altitude) + h1)
                
                Text("\(Int(plan!.routes.last!.points.last!.altitude))m")
                    .font(.footnote)
                    .position(x: w1 + w2, y: h2 / CGFloat(maxHeight - minHeight) * CGFloat(maxHeight - plan!.routes.last!.points.last!.altitude) + h1)
                
                Path { path in
                    path.move(to: CGPoint(x: 0, y: Double(h2) / (maxHeight - minHeight) * (maxHeight - plan!.routes[0].points[0].altitude) + Double(h1)))
                    for (x, y) in chartPoints {
                        path.addLine(to: CGPoint(x: Double(w1) / dist * x, y: Double(h2) / (maxHeight - minHeight) * (maxHeight - y) + Double(h1)))
                    }
                }.stroke(CU_PURPLE, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                
                Path { path in
                    path.move(to: CGPoint(x: 0, y: height))
                    for (x, y) in chartPoints {
                        path.addLine(to: CGPoint(x: Double(w1) / dist * x, y: Double(h2) / (maxHeight - minHeight) * (maxHeight - y) + Double(h1)))
                    }
                    path.addLine(to: CGPoint(x: w1, y: height))
                }.fill(CU_PURPLE.opacity(0.5))
                
                Image(systemName: "circlebadge")
                    .imageScale(.large)
                    .background(Color.white)
                    .cornerRadius(100)
                    .position(x: 0, y: h2 / CGFloat(maxHeight - minHeight) * CGFloat(maxHeight - plan!.routes.first!.points.first!.altitude) + h1)
                
                Image(systemName: "smallcircle.fill.circle")
                    .background(Color.white)
                    .cornerRadius(100)
                    .position(x: w1, y: h2 / CGFloat(maxHeight - minHeight) * CGFloat(maxHeight - plan!.routes.last!.points.last!.altitude) + h1)
            }
            .frame(width: width, height: height, alignment: .center)
        }
    }
}


struct Instructions: View {
    @State var plan: Plan?
    
    var body: some View {
        if let plan = plan {
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
                        if route == plan.routes.first { // first route
                            HStack(spacing: 20) {
                                Image(systemName: "circlebadge").imageScale(.large).frame(width: 20)
                                Text(plan.startLoc!.nameEn).font(.title3)
                                Spacer()
                            }.padding()
                        }
                        
                        if route.type == .onFoot {
                            HStack(spacing: 20) {
                                Image(systemName: "figure.walk").frame(width: 20)
                                Text("Walk for \(Int(route.dist/SPEED_ON_FOOT/60)) min (\(Int(route.dist)) m)")
                                Spacer()
                            }.padding()
                        } else if route.type == .byBus {
                            HStack(spacing: 20) {
                                Image(systemName: "bus").frame(width: 20)
                                // TODO: bus info
                                Text("Take bus \(route.bus!.line) for \(Int(route.dist/SPEED_BY_BUS/60)) min (\(Int(route.dist)) m)")
                                Spacer()
                            }.padding()
                        }

                        HStack(spacing: 20) {
                            if route == plan.routes.last { // last route
                                Image(systemName: "smallcircle.fill.circle").frame(width: 20)
                            } else {
                                Image(systemName: "circlebadge").imageScale(.large).frame(width: 20)
                            }
                            Text(route.endLoc.nameEn).font(.title3)
                            Spacer()
                        }.padding()
                    }
                }
            }
        }
    }
}
