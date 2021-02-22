// MARK: The page for searching routes between A and B

import SwiftUI
import MapKit

// height of plansView sheet
let smallH = UIScreen.main.bounds.height * 0.25
let mediumH = UIScreen.main.bounds.height * 0.55
let largeH = UIScreen.main.bounds.height * 0.9


struct RouteSearchPage: View {
    // data
    @State var locations: [Location]
    @State var routes: [Route]
    @State var buses: [Bus]
    
    // selected start/end loc
    @State var startLoc: Location? = nil
    @State var endLoc: Location? = nil
    @Binding var current: Coor3D
    
    // plans
    @State var plans: [Plan] = [] // just for keep data temply
    @State var busPlans: [BusPlan] = []
    @State var walkPlans: [Plan] = []
    @State var chosenPlan: Plan? = nil
    
    // other date
    @State var mode: TransMode = .bus
    @State var angle = 0.0 // animation for 􀄬
    @State var showStartList: Bool = false
    @State var showEndList: Bool = false
    @Binding var showing: Bool
    
    @State var lastHeight: CGFloat = smallH
    @State var height: CGFloat = smallH
    
    var body: some View {
        // find min time for both mode
        var footTime = INF
        var busTime = INF
        for plan in busPlans {
            busTime = min(busTime, plan.plan.time)
        }
        for plan in walkPlans {
            footTime = min(footTime, plan.time)
        }
        return ZStack {
            // MapView
            RouteMapView(startLoc: $startLoc, endLoc: $endLoc, chosenPlan: $chosenPlan, current: $current)
                .ignoresSafeArea(.all)
            
            // searchView
            VStack {
                VStack {
                    Color.white.frame(maxWidth: .infinity, maxHeight: UIScreen.main.bounds.height / 18)
                    // search box
                    HStack {
                        // back button
                        Image(systemName: "arrowshape.turn.up.left.fill")
                            .onTapGesture {
                                showing.toggle()
                            }
                        // text field
                        VStack {
                            VStack(spacing: 12) {
                                NavigationLink(destination: LocListPage(placeholder: "From", keyword: startLoc == nil ? "" : startLoc!.name_en, locations: locations, showCurrent: true, location: $startLoc, showing: $showStartList), isActive: $showStartList) {
                                    Text(startLoc == nil ? "From" : startLoc!.name_en)
                                        .foregroundColor(startLoc == nil ? .gray : .black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding()
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 0.8))
                                
                                NavigationLink(destination: LocListPage(placeholder: "To", keyword: endLoc == nil ? "" : endLoc!.name_en, locations: locations, showCurrent: true, location: $endLoc, showing: $showEndList), isActive: $showEndList) {
                                    Text(endLoc == nil ? "To" : endLoc!.name_en)
                                        .foregroundColor(endLoc == nil ? .gray : .black)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .padding()
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 0.8))
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                        // switch button
                        Image(systemName: "arrow.up.arrow.down")
                            .rotationEffect(.degrees(angle))
                            .animation(Animation.easeInOut(duration: 0.1))
                            .onTapGesture {
                                angle += 180
                                let tmp = startLoc
                                startLoc = endLoc
                                endLoc = tmp
                                RP()
                            }
                    }
                    // search mode
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 30) {
                            HStack {
                                Image(systemName: "bus").foregroundColor(Color.black.opacity(0.7))
                                if startLoc != nil && endLoc != nil {
                                    busTime == INF ? Text("—") : Text("\(Int(busTime)) min")
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(mode == .bus ? CUPurple.opacity(0.2) : nil)
                            .cornerRadius(20)
                            .onTapGesture {
                                mode = .bus
                                chosenPlan = nil
                            }
                            HStack {
                                Image(systemName: "figure.walk").foregroundColor(Color.black.opacity(0.7))
                                if startLoc != nil && endLoc != nil {
                                    footTime == INF ? Text("—") : Text("\(Int(footTime)) min")
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(mode == .foot ? CUPurple.opacity(0.2) : nil)
                            .cornerRadius(20)
                            .onTapGesture {
                                mode = .foot
                                chosenPlan = nil
                            }
                        }
                    }.gesture(DragGesture())
                }
                .padding()
                .background(Color.white)
                .clipped()
                .shadow(radius: 5)
                .offset(y: height > smallH ? (smallH - height) * 2 : 0)
                Spacer()
            }
            .ignoresSafeArea(.all)

            // plansView
            PlansView(buses: buses, busPlans: $busPlans, walkPlans: $walkPlans, chosenPlan: $chosenPlan, mode: $mode, lastHeight: $lastHeight, height: $height)
        }
        .onAppear {
            RP()
        }
        .navigationBarHidden(true)
    }
    private func RP() {
        // Step 1: Clear result
        plans = []
        busPlans = []
        walkPlans = []
        
        // Step 2: Deal with nil input
        if startLoc == nil || endLoc == nil { return }
        
        // Step 3: Deal with current location
        let curLoc = Location(_id: UUID().uuidString, name_en: "Your Location", latitude: current.latitude, longitude: current.longitude, altitude: current.altitude, type: 0)
        var newLocs = locations
        var newRoutes: [Route] = []
        if startLoc!.name_en == "Your Location" || endLoc!.name_en == "Your Location" {
            if startLoc!.name_en == "Your Location" { startLoc = curLoc }
            if endLoc!.name_en == "Your Location" { endLoc = curLoc }
            // newLocs
            newLocs.append(curLoc)
            // newRoutes
            for route in routes {
                if route.type != 0 { newRoutes.append(route); continue } // only consider route on foot
                // find point holding minDist from curLoc in a route
                var index = -1
                var minDist = INF
                for i in 0..<route.points.count {
                    if distance(location: curLoc, point: route.points[i]) < minDist {
                        minDist = distance(location: curLoc, point: route.points[i])
                        index = i
                    }
                }
                // print("min: \(minDist)")
                if minDist > 100 { // TODO: what if cant find closest point?
                    newRoutes.append(route)
                } else {
                    // split route
                    var route1 = Route(_id: route._id + "1", startLoc: route.startLoc, endLoc: curLoc, points: Array(route.points[0...index]), dist: 0, type: 0)
                    var route2 = Route(_id: route._id + "2", startLoc: curLoc, endLoc: route.endLoc, points: Array(route.points[index..<route.points.count]), dist: 0, type: 0)
                    // calculate distance
                    if route1.points.count > 1 {
                        for i in 0...route1.points.count - 2 {
                            route1.dist += distance(start: route1.points[i], end: route1.points[i + 1]);
                        }
                    }
                    if route2.points.count > 1 {
                        for i in 0...route2.points.count - 2 {
                            route2.dist += distance(start: route2.points[i], end: route2.points[i + 1]);
                        }
                    }
                    let index1: Int? = newRoutes.firstIndex(where: {
                        ($0.startLoc == route1.startLoc && $0.endLoc == route1.endLoc) || ($0.startLoc == route1.endLoc && $0.endLoc == route1.startLoc)
                    })
                    let index2: Int? = newRoutes.firstIndex(where: {
                        ($0.startLoc == route2.startLoc && $0.endLoc == route2.endLoc) || ($0.startLoc == route2.endLoc && $0.endLoc == route2.startLoc)
                    })
                    
                    if index1 == nil {
                        newRoutes.append(route1)
                    } else if newRoutes[index1!].dist > route1.dist {
                        newRoutes.remove(at: index1!)
                        newRoutes.append(route1)
                    }
                    
                    if index2 == nil {
                        newRoutes.append(route2)
                    } else if newRoutes[index2!].dist > route2.dist {
                        newRoutes.remove(at: index2!)
                        newRoutes.append(route2)
                    }
                }
            }
        } else {
            newRoutes = routes
        }
        
        // Step 4: Searching for route plans
        checkNextRoute(plan: Plan(startLoc: nil, endLoc: nil, routes: [], dist: 0, time: 0, ascent: 0, type: 0), locs: newLocs, routes: newRoutes)
        
        // Step 5: process plans
        // if a bus plan contains a walking route which can be replaced by taking bus, remove that plan
        for plan in plans {
            if plan.type != 1 { continue }
            for route in plan.routes {
                if route.type == 0 && !routes.filter({$0.type == 1 && $0.startLoc == route.startLoc && $0.endLoc == route.endLoc}).isEmpty {
                    let index = plans.firstIndex(where: {$0.id == plan.id})!
                    plans.remove(at: index)
                    break
                }
            }
        }
        
        // combine walking route in bus plan
        for i in 0..<plans.count {
            if plans[i].type != 1 {
                continue
            }
            
            var j = 0
            while j < plans[i].routes.count - 1 {
                if plans[i].routes[j].type == 0 && plans[i].routes[j+1].type == 0 {
                    let newRoute = Route(_id: plans[i].routes[j]._id + plans[i].routes[j+1]._id, startLoc: plans[i].routes[j].startLoc, endLoc: plans[i].routes[j+1].endLoc, points: plans[i].routes[j].points + plans[i].routes[j+1].points, dist: plans[i].routes[j].dist + plans[i].routes[j+1].dist, type: 0)
                    plans[i].routes.remove(at: j)
                    plans[i].routes.remove(at: j)
                    plans[i].routes.insert(newRoute, at: j)
                } else {
                    j += 1
                }
            }
        }
        
        // Step 6: generate walk/bus plans
        for plan in plans {
            if plan.type == 0 {
                walkPlans.append(plan)
            } else {
                busPlans += planToBusPlans(plan: plan)
            }
        }
        
        // Step 7: combine adjacent same bus
        for i in 0..<busPlans.count {
            var j = 0
            while j < busPlans[i].busIds.count - 1 {
                if busPlans[i].busIds[j] != nil && busPlans[i].busIds[j] == busPlans[i].busIds[j+1] {
                    let route1 = busPlans[i].plan.routes[j]
                    let route2 = busPlans[i].plan.routes[j+1]
                    let newRoute = Route(_id: route1._id + route2._id, startLoc: route1.startLoc, endLoc: route2.endLoc, points: route1.points + route2.points, dist: route1.dist + route2.dist, type: 1)
                    busPlans[i].busIds.remove(at: j)
                    busPlans[i].plan.routes.remove(at: j)
                    busPlans[i].plan.routes.remove(at: j)
                    busPlans[i].plan.routes.insert(newRoute, at: j)
                } else {
                    j += 1
                }
            }
        }
        
        // Step 8: remove bus plan which contains more than 2 bus
        var i = 0
        while i < busPlans.count {
            if busPlans[i].busIds.filter({$0 != nil}).count >= 3 {
                busPlans.remove(at: i)
            } else {
                i += 1
            }
        }
        
        chosenPlan = nil
    }
    
    // DFS recursion
    private func checkNextRoute(plan: Plan, locs: [Location], routes: [Route]) {
        if plan.startLoc == startLoc && plan.endLoc == endLoc {
            plans.append(plan)
            return
        }
        
        if plan.startLoc == nil { // to find the first route
            for route in routes {
                if route.startLoc == startLoc {
                    var plan = plan
                    plan.startLoc = route.startLoc
                    plan.endLoc = route.endLoc
                    plan.routes.append(route)
                    plan.dist += route.dist
                    if route.type == 0 {
                        plan.time += route.dist/footSpeed/60
                    } else {
                        plan.time += route.dist/busSpeed/60 + 0.25
                    }
                    plan.type = (plan.type == 1 || route.type == 1) ? 1 : 0
                    checkNextRoute(plan: plan, locs: locs, routes: routes)
                } else if route.endLoc == startLoc && route.type == 0 {
                    var plan = plan
                    plan.startLoc = route.endLoc
                    plan.endLoc = route.startLoc
                    plan.routes.append(Route(_id: route._id, startLoc: route.endLoc, endLoc: route.startLoc, points: route.points.reversed(), dist: route.dist, type: route.type))
                    plan.dist += route.dist
                    plan.time += route.dist / footSpeed / 60 // must be on foot
                    checkNextRoute(plan: plan, locs: locs, routes: routes)
                }
            }
        } else { // continue to find following routes
            for route in routes {
                if route.startLoc == plan.endLoc {
                    if !plan.routes.filter({$0.startLoc == route.endLoc || $0.endLoc == route.endLoc}).isEmpty { continue }
                    // if route.type == 0 && isOverlapped(points1: plan.routes.last!.points, points2: route.points) { continue }
                    if isOverlapped(route1: plan.routes.last!, route2: route) { continue }
                    var plan = plan
                    plan.endLoc = route.endLoc
                    plan.routes.append(route)
                    plan.dist += route.dist
                    if route.type == 0 {
                        plan.time += route.dist/footSpeed/60
                    } else {
                        plan.time += route.dist/busSpeed/60 + 0.25
                    }
                    // plan.time += route.type == 0 ? route.dist/footSpeed/60 : route.dist/busSpeed/60
                    plan.type = (plan.type == 1 || route.type == 1) ? 1 : 0
                    checkNextRoute(plan: plan, locs: locs, routes: routes)
                } else if route.endLoc == plan.endLoc && route.type == 0 {
                    if !plan.routes.filter({$0.startLoc == route.startLoc || $0.endLoc == route.startLoc}).isEmpty { continue }
                    // if isOverlapped(points1: plan.routes.last!.points, points2: route.points) { continue }
                    if isOverlapped(route1: plan.routes.last!, route2: route) { continue }
                    var plan = plan
                    plan.endLoc = route.startLoc
                    plan.routes.append(Route(_id: route._id, startLoc: route.endLoc, endLoc: route.startLoc, points: route.points.reversed(), dist: route.dist, type: route.type))
                    plan.dist += route.dist
                    plan.time += route.dist / footSpeed / 60 // must be on foot
                    checkNextRoute(plan: plan, locs: locs, routes: routes)
                }
            }
        }
    }
    
    private func isOverlapped(route1: Route, route2: Route) -> Bool {
        if route1.type == 0 && route2.type == 0 {
            var count = 0
            for point in route2.points {
                if route1.points.contains(point) {
                    count += 1
                }
                if count == 3 {
                    return true
                }
            }
        } else if route1.type == 1 && route2.type == 0 {
            var count = 0
            for point2 in route2.points {
                for point1 in route1.points {
                    if distance(start: point1, end: point2) < 5 {
                        count += 1
                        break
                    }
                }
                if count == 3 {
                    return true
                }
            }
        }
        return false
    }
    
    // MARK: - find bus plans
    @State var result: [BusPlan] = []
    
    private func planToBusPlans(plan: Plan) -> [BusPlan] {
        // find bus id sequence of plan.routes
        var busIds: [[String]] = [[String]] (repeating: [], count: plan.routes.count) // in plan.routes order
        for i in 0..<plan.routes.count { // for each bus route
            if plan.routes[i].type == 0 { continue }
            let filteredBuses = buses.filter({ hasRoute(bus: $0, route: plan.routes[i])})
            for filteredBus in filteredBuses {
                busIds[i].append(filteredBus.id)
            }
        }
        if plan.routes.filter({ $0.type == 0 }).count != busIds.filter({ $0.isEmpty }).count {
            return []
        }
        
        // generate bus plan
        result = []
        busIdsToPlan(plan: plan, busIds: busIds, busIdsIndex: 0, curPlan: BusPlan(plan: plan, busIds: []))
        return result
    }
    
    private func hasRoute(bus: Bus, route: Route) -> Bool {
        for i in 0..<bus.stops.count - 1 {
            if bus.stops[i] == route.startLoc._id && bus.stops[i+1] == route.endLoc._id {
                return true
            }
        }
        return false
    }
    
    private func busIdsToPlan(plan: Plan, busIds: [[String]], busIdsIndex: Int, curPlan: BusPlan) {
        var curPlan = curPlan
        if busIdsIndex >= busIds.count {
            result.append(curPlan)
            return
        }
        
        for i in busIdsIndex..<busIds.count {
            if busIds[i].isEmpty {
                curPlan.busIds.append(nil)
            } else {
                for busId in busIds[i] {
                    busIdsToPlan(plan: plan, busIds: busIds, busIdsIndex: i+1, curPlan: BusPlan(plan: curPlan.plan, busIds: curPlan.busIds + [busId]))
                }
                break
            }
        }
    }
}


var lineColor: Color = CUYellow

struct RouteMapView: UIViewRepresentable {
    @Binding var startLoc: Location?
    @Binding var endLoc: Location?
    @Binding var chosenPlan: Plan?
    @Binding var current: Coor3D
    
    @State var trackingMode: MKUserTrackingMode = .follow
    
    // annotation
    @State var startAnt = MKPointAnnotation()
    @State var endAnt = MKPointAnnotation()
    
    func makeUIView (context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        return mapView
    }
    
    func updateUIView (_ mapView: MKMapView, context: Context) {
        // update start/end annotation
        if startLoc != nil {
            startAnt.title = "Start"
            startAnt.subtitle = startLoc!.name_en
            startAnt.coordinate = CLLocationCoordinate2D(latitude: startLoc!.latitude, longitude: startLoc!.longitude)
            mapView.addAnnotation(startAnt)
        } else {
            mapView.removeAnnotation(startAnt)
        }
        if endLoc != nil {
            endAnt.title = "End"
            endAnt.subtitle = endLoc!.name_en
            endAnt.coordinate = CLLocationCoordinate2D(latitude: endLoc!.latitude, longitude: endLoc!.longitude)
            mapView.addAnnotation(endAnt)
        } else {
            mapView.removeAnnotation(endAnt)
        }
        
        // update plan annotation
        mapView.removeOverlays(mapView.overlays)
        if chosenPlan != nil {
            var busPolylines: [MKPolyline] = []
            var walkPolylines: [MKPolyline] = []
            for route in chosenPlan!.routes {
                var points: [CLLocationCoordinate2D] = []
                for point in route.points {
                    points.append(CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude))
                }
                if route.type == 0 { // walk
                    walkPolylines.append(MKPolyline(coordinates: points, count: points.count))
                } else { // bus
                    busPolylines.append(MKPolyline(coordinates: points, count: points.count))
                }
            }
            lineColor = CUPurple
            mapView.addOverlay(MKMultiPolyline(busPolylines))
            lineColor = CUYellow
            mapView.addOverlay(MKMultiPolyline(walkPolylines))
        }
    }
    
    func makeCoordinator () -> Coordinator {
        return Coordinator(self)
    }
    
    // delegate
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: RouteMapView
        
        init (_ parent: RouteMapView) {
            self.parent = parent
        }
        
        // render layout
        func mapView (_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay is MKMultiPolyline {
                let renderer = MKMultiPolylineRenderer(multiPolyline: overlay as! MKMultiPolyline)
                renderer.strokeColor = UIColor(lineColor)
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer()
        }
        
        func mapViewDidFinishLoadingMap (_ mapView: MKMapView) {
            mapView.setUserTrackingMode(.follow, animated: true)
        }
    }
}


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

struct PlansView: View {
    @State var buses: [Bus]
    @Binding var busPlans: [BusPlan]
    @Binding var walkPlans: [Plan]
    @Binding var chosenPlan: Plan?
    
    @State var departDate: Date = Date()
    
    @Binding var mode: TransMode
    
    @Binding var lastHeight: CGFloat
    @Binding var height: CGFloat
    
    // gesture
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
                    // "􀌇" or "back + 􀌇"
                    if chosenPlan == nil {
                        Image(systemName: "line.horizontal.3")
                            .foregroundColor(Color.gray)
                            .padding()
                    } else {
                        HStack {
                            Button(action: {
                                chosenPlan = nil
                            }) {
                                HStack {
                                    Image(systemName: "arrow.uturn.backward")
                                    Text("Back")
                                }
                            }
                            Spacer()
                            Image(systemName: "line.horizontal.3")
                                .foregroundColor(Color.gray)
                            Spacer()
                            HStack {
                                Image(systemName: "arrow.uturn.backward")
                                Text("Back")
                            }.hidden()
                        }.padding()
                    }
                    
                    // content starting here
                    if chosenPlan != nil {
                        // display a plan
                        HStack {
                            Text("\(Int(chosenPlan!.time))").font(.title2).bold()
                            Text("min").font(.title2)
                            Text("(\(Int(chosenPlan!.dist)) m)").font(.title3).foregroundColor(Color.gray)
                            Spacer()
                        }.padding(.horizontal).padding(.bottom)
                        
                        Divider()
                        
                        ScrollView(.vertical) {
                            VStack(spacing: 0) {
                                // chart
                                HeightChart(plan: chosenPlan)
                                    .frame(width: UIScreen.main.bounds.size.width * 0.9, height: UIScreen.main.bounds.size.width * 0.25, alignment: .center)
                                    .padding(.vertical)
                                Divider()

                                // Alert
                                HStack(spacing: 20) {
                                    Image(systemName: "exclamationmark.circle.fill")
                                        .imageScale(.large)
                                        .foregroundColor(CUYellow)
                                    Text("The estimated time to arrive may not be accurate.")
                                    Spacer()
                                }.padding()
                                Divider()
                                // steps
                                Instructions(plan: chosenPlan)
                                Divider()
                            }
                        }
                        .padding(.bottom, geometry.safeAreaInsets.bottom)
                        .frame(maxHeight: height - geometry.safeAreaInsets.bottom * 2)
                        .gesture(DragGesture()) // prevent changing height when scrolling
                    } else if mode == .foot {
                        if walkPlans.isEmpty {
                            Text("No results")
                        } else {
                            ScrollView {
                                VStack(spacing: 0) {
                                    Divider()
                                    ForEach(walkPlans) { plan in
                                        // TODO: change display of walk plan
                                        Button(action: {
                                            chosenPlan = plan
                                        }) {
                                            HStack {
                                                Spacer()
                                                Text("\(Int(plan.time)) min (\(Int(plan.dist)) m)")
                                                Text(">").bold()
                                            }
                                            .padding()
                                            .contentShape(Rectangle())
                                        }.buttonStyle(MyButtonStyle2(bgColor: Color.gray.opacity(0.3)))
                                        Divider()
                                    }
                                }
                            }
                            .padding(.bottom, geometry.safeAreaInsets.bottom)
                            .frame(height: height - geometry.safeAreaInsets.bottom * 2)
                            .gesture(DragGesture()) // prevent changing height when scrolling
                        }
                    } else if mode == .bus {
                        DatePicker("Depart at", selection: $departDate).padding(.horizontal)
                            .onChange(of: departDate, perform: { value in
                                print(value) // TODO: change plan time by current time
                            })
                        if busPlans.isEmpty {
                            Text("No results")
                        } else {
                            ScrollView {
                                VStack(spacing: 0) {
                                    Divider()
                                    ForEach(busPlans) { busPlan in
                                        Button(action: {
                                            chosenPlan = busPlan.plan
                                        }) {
                                            HStack {
                                                ForEach(busPlan.busIds, id: \.self) { busId in
                                                    let index = busPlan.busIds.firstIndex(of: busId)!
                                                    if busId == nil {
                                                        HStack(alignment: .bottom, spacing: 0) {
                                                            Image(systemName: "figure.walk")
                                                                .foregroundColor(Color.black.opacity(0.8))
                                                            Text("\(Int(busPlan.plan.routes[index].dist / footSpeed / 60))")
                                                                .font(.footnote).foregroundColor(.gray)
                                                        }
                                                    } else {
                                                        HStack(alignment: .bottom, spacing: 0) {
                                                            Image(systemName: "bus.fill")
                                                                .foregroundColor(Color.white)
                                                                .padding(4)
                                                                .background(CUPurple)
                                                                .clipShape(Circle())
                                                            Text(busId!)
                                                                .font(.footnote).foregroundColor(.gray)
                                                        }
                                                    }
                                                    if index != busPlan.busIds.count - 1 {
                                                        Text(">").font(.footnote).foregroundColor(Color.black.opacity(0.8))
                                                    }
                                                }
                                                Spacer()
                                                Text("\(Int(busPlan.plan.time)) mins >")
                                            }
                                            .frame(maxWidth: .infinity)
                                            .padding()
                                            .contentShape(Rectangle())
                                        }.buttonStyle(MyButtonStyle2(bgColor: Color.gray.opacity(0.3)))
                                        Divider()
                                    }
                                }
                            }
                            .padding(.bottom, height == largeH ? geometry.safeAreaInsets.bottom : 0)
                            .frame(height: height - geometry.safeAreaInsets.bottom * 2)
                            .gesture(DragGesture()) // prevent changing height when scrolling
                            
                        }
                    }
                    // content ending here
                }
                .frame(maxWidth: .infinity, maxHeight: largeH, alignment: .top)
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
    @State var plan: Plan?
    
    var body: some View {
        // find max, min altitude
        var maxHeight = -INF
        var minHeight = INF
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
        ZStack {
            // timeline sign
            VStack(alignment: .leading, spacing: 0) {
                HStack(spacing: 20) {
                    Divider().frame(width: 20)
                    Spacer()
                }.padding()
            }
            
            VStack(alignment: .leading, spacing: 0) {
                ForEach(plan!.routes) { route in
                    if route == plan!.routes.first! { // first route
                        HStack(spacing: 20) {
                            Image(systemName: "circlebadge").imageScale(.large).frame(width: 20)
                            Text(plan!.startLoc!.name_en).font(.title3)
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
                        if route == plan!.routes.last! { // last route
                            Image(systemName: "smallcircle.fill.circle").frame(width: 20)
                        } else {
                            Image(systemName: "circlebadge").imageScale(.large).frame(width: 20)
                        }
                        Text(route.endLoc.name_en).font(.title3)
                        Spacer()
                    }.padding()
                }
            }
        }
    }
}
