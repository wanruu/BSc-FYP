import SwiftUI

struct NaviPage: View {
    @EnvironmentObject var locationModel: LocationModel
    
    // input data
    @State var locations: [Location]
    @State var buses: [Bus]
    @State var routesOnFoot: [Route]
    @State var routesByBus: [Route]
    
    // user selected
    @State var startLoc: Location? = nil
    @State var endLoc: Location? = nil
    @State var planType = PlanType.byBus
    
    // result
    @State var plansByBus: [Plan] = []
    @State var plansOnFoot: [Plan] = []
    @State var selectedPlan: Plan? = nil
    @State var minTimeByBus: Double = .infinity // min
    @State var minTimeOnFoot: Double = .infinity

    @Binding var showing: Bool

    @State var lastOffset = CGSize.zero
    @State var offset = CGSize.zero
    
    var body: some View {
        VStack(spacing: 0) {
            
            SearchAreaView(locations: locations, startLoc: $startLoc, endLoc: $endLoc, planType: $planType, minTimeByBus: $minTimeByBus, minTimeOnFoot: $minTimeOnFoot, showing: $showing)
            
            NaviMapView(startLoc: $startLoc, endLoc: $endLoc, selectedPlan: $selectedPlan)
                //.ignoresSafeArea(.all)
            
            PlansByBusView(plansByBus: $plansByBus, selectedPlan: $selectedPlan)
                
            /*PlansOnFootView(plansOnFoot: $plansOnFoot, selectedPlan: $selectedPlan)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            offset.width = lastOffset.width + value.location.x - value.startLocation.x
                            offset.height = lastOffset.height + value.location.y - value.startLocation.y
                        }
                        .onEnded{ _ in
                            lastOffset = offset
                        }
                )*/

        }
        .navigationBarHidden(true)
        .onChange(of: startLoc) { _ in
            RP()
        }
        .onChange(of: endLoc) { _ in
            RP()
        }
    }
    
    private func RP() {
        // Step 1: Clear result
        plansOnFoot.removeAll()
        plansByBus.removeAll()
        selectedPlan = nil
        
        // Step 2: Deal with nil input
        if startLoc == nil || endLoc == nil {
            return
        }
        // guard var startLoc = startLoc, var endLoc = endLoc else { return }
        
        // Step 3: Consider current location and generate new data for processing
        var newLocs = locations
        var newRoutesOnFoot: [Route] = []
        
        if startLoc!.type == .user || endLoc!.type == .user {
            let curLoc = Location(id: UUID().uuidString, nameEn: "Your Location", nameZh: "你的位置", latitude: locationModel.current.latitude, longitude: locationModel.current.longitude, altitude: locationModel.current.altitude, type: .user)
            if startLoc!.type == .user {
                startLoc = curLoc
            } else {
                endLoc = curLoc
            }
            newLocs.append(curLoc)
            
            for route in routesOnFoot {
                // find closest point
                var closestPointIndex = -1
                var minDist: Double = .infinity
                for index in 0..<route.points.count {
                    let dist = curLoc.distance(from: route.points[index])
                    if dist < minDist {
                        minDist = dist
                        closestPointIndex = index
                    }
                }
                
                if minDist > 100 {
                    newRoutesOnFoot.append(route)
                } else {
                    // split route
                    var route1 = Route(id: UUID().uuidString, startLoc: route.startLoc, endLoc: curLoc, points: Array(route.points[0...closestPointIndex]), dist: 0, type: .onFoot)
                    if route1.points.count > 1 {
                        for i in 0...route1.points.count - 2 {
                            route1.dist += distance(from: route1.points[i], to: route1.points[i + 1])
                        }
                    }
                    newRoutesOnFoot.append(route1)
                    newRoutesOnFoot.append(Route(id: UUID().uuidString, startLoc: curLoc, endLoc: route.endLoc, points: Array(route.points[closestPointIndex..<route.points.count]), dist: route.dist - route1.dist, type: .onFoot))
                }
            }
        } else {
            newRoutesOnFoot = routesOnFoot
        }
        
        // Step 4: Searching for route plans
        
        // on foot
        checkRoutesOnFoot(locations: newLocs, routes: routesOnFoot, curStartLoc: nil, curEndLoc: nil, curRoutes: [])
        plansOnFoot.sort(by: { $0.dist < $1.dist})
        if planType == .onFoot {
            selectedPlan = plansOnFoot.first
        }
        
        // by bus
        // find nearest bus stop
        let startStops = startLoc!.type == .busStop ? [startLoc!] : findBusStops(cur: startLoc!, stops: locations.filter({ $0.type == .busStop }), maxDist: 400)
        let endStops = endLoc!.type == .busStop ? [endLoc!] : findBusStops(cur: endLoc!, stops: locations.filter({ $0.type == .busStop }), maxDist: 400)
        
        var routesList: [[RouteByBus]] = []
        for startStop in startStops {
            for endStop in endStops {
                routesList += findRoutes(startStop: startStop, endStop: endStop, buses: buses)
            }
        }
        
        // deduplicate
        var removedIndexes: [Int] = []
        for i in 0..<routesList.count {
            if i != routesList.lastIndex(where: { routes -> Bool in
                routes.map({ $0.bus.line }) == routesList[i].map({ $0.bus.line })
            }) {
                removedIndexes.append(i)
            }
        }
        routesList.remove(atOffsets: IndexSet(removedIndexes))
        
        for routes in routesList {
            var routes = routes
            for i in 0..<routes.count {
                let tmp = routesByBus.first(where: { $0.startLoc == routes[i].startLoc && $0.endLoc == routes[i].endLoc })
                routes[i].points = tmp?.points ?? []
                routes[i].dist = tmp?.dist ?? -1
            }
            var dist = 0.0
            for route in routes {
                dist += route.dist
            }
            plansByBus.append(Plan(startLoc: startLoc, endLoc: endLoc, routes: routes, dist: dist, time: 0, ascent: 0, type: .byBus))
            print(routes.map({ $0.bus.line }))
        }
    }
    
    // DFS recursion for find plan on foot
    // routes: routesOnFoot
    private func checkRoutesOnFoot(locations: [Location], routes: [Route], curStartLoc: Location?, curEndLoc: Location?, curRoutes: [Route]) {
        if curStartLoc == nil && curEndLoc == nil { // find first routes
            for route in routes {
                if route.startLoc == self.startLoc {
                    checkRoutesOnFoot(locations: locations, routes: routes, curStartLoc: route.startLoc, curEndLoc: route.endLoc, curRoutes: [route])
                }
                if route.endLoc == self.startLoc {
                    let newRoute = Route(id: UUID().uuidString, startLoc: route.endLoc, endLoc: route.startLoc, points: route.points.reversed(), dist: route.dist, type: route.type)
                    checkRoutesOnFoot(locations: locations, routes: routes, curStartLoc: route.endLoc, curEndLoc: route.startLoc, curRoutes: [newRoute])
                }
            }
            return
        }
        if curEndLoc == self.endLoc { // return result
            var dist: Double = 0
            for route in curRoutes {
                dist += route.dist
            }
            // TODO: calculate
            let plan = Plan(startLoc: curStartLoc, endLoc: curEndLoc, routes: curRoutes, dist: dist, time: 0, ascent: 0, type: .onFoot)
            plansOnFoot.append(plan)
        } else {
            for route in routes {
                if route.startLoc == curEndLoc && !isBack(routes: curRoutes, newRoute: route) {
                    checkRoutesOnFoot(locations: locations, routes: routes, curStartLoc: curStartLoc, curEndLoc: route.endLoc, curRoutes: curRoutes + [route])
                }
                
                if route.endLoc == curEndLoc {
                    let newRoute = Route(id: UUID().uuidString, startLoc: route.endLoc, endLoc: route.startLoc, points: route.points.reversed(), dist: route.dist, type: route.type)
                    if !isBack(routes: curRoutes, newRoute: newRoute) {
                        checkRoutesOnFoot(locations: locations, routes: routes, curStartLoc: curStartLoc, curEndLoc: route.startLoc, curRoutes: curRoutes + [newRoute])
                    }
                }
            }
        }
    }
    
    private func isBack(routes: [Route], newRoute: Route) -> Bool {
        var count = 0
        for newPoint in newRoute.points {
            if newPoint == newRoute.points.first {
                continue
            }
            for route in routes {
                if route.points.contains(newPoint) {
                    count += 1
                    break
                }
            }
            if count > 0 {
                return true
            }
        }
        return false
    }
    
    
    private func findBusStops(cur: Location, stops: [Location], maxDist: Double) -> [Location] {
        var result: [Location] = []
        for stop in stops {
            let dist = distance(from: cur, to: stop)
            if dist < maxDist {
                result.append(stop)
            }
        }
        return result
    }
    
    private func findDirectRoutes(startStop: Location, endStop: Location, bus: Bus) -> [RouteByBus] {
        for bus in buses {
            let startIndex1 = bus.stops.firstIndex(of: startStop) ?? -1
            let startIndex2 = bus.stops.lastIndex(of: startStop) ?? -1
            let endIndex1 = bus.stops.firstIndex(of: endStop) ?? -1
            let endIndex2 = bus.stops.lastIndex(of: endStop) ?? -1
            
            var startIndex = startIndex1
            var endIndex = endIndex1

            if startIndex1 == startIndex2 {
                if endIndex1 != endIndex2 && startIndex > endIndex1 {
                    endIndex = endIndex2
                }
            } else {
                if endIndex1 == endIndex2 {
                    if startIndex2 < endIndex {
                        startIndex = startIndex2
                    }
                } else {
                    if startIndex1 > endIndex1 && startIndex2 < endIndex2 {
                        startIndex = startIndex2
                        endIndex = endIndex2
                    }
                }
            }
            
            if startIndex < endIndex && startIndex != -1 && endIndex != -1 {
                var newRoutes: [RouteByBus] = []
                for i in startIndex..<endIndex {
                    newRoutes.append(RouteByBus(bus: bus, startLoc: bus.stops[i], endLoc: bus.stops[i+1], points: [], dist: 0))
                }
                return newRoutes
            }
        }
        return []
    }
    
    // transfer at most 2 time
    private func findRoutes(startStop: Location, endStop: Location, buses: [Bus]) -> [[RouteByBus]] {
        var result: [[RouteByBus]] = []
        for firstBus in buses { // consider first bus
            if !firstBus.stops.contains(startStop) {
                continue
            }
            // find direct routes
            var routes = findDirectRoutes(startStop: startStop, endStop: endStop, bus: firstBus)
            if routes.isEmpty { // no direct routes
                let index1 = firstBus.stops.firstIndex(of: startStop) ?? -1
                let index2 = firstBus.stops.lastIndex(of: startStop) ?? -1
                print(index1, index2)
                // for each stops succeed startStop in first bus (also need differ from startStop
                for i in index1+1..<firstBus.stops.count {
                    if i == index2 {
                        continue
                    }
                    routes.append(RouteByBus(bus: firstBus, startLoc: firstBus.stops[i-1], endLoc: firstBus.stops[i], points: [], dist: 0))
                    for secondBus in buses {
                        if secondBus.line != firstBus.line {
                            let secondRoutes = findDirectRoutes(startStop: firstBus.stops[i], endStop: endStop, bus: secondBus)
                            if !secondRoutes.isEmpty {
                                result.append(routes + secondRoutes)
                            }
                        }
                    }
                }
                
            } else {
                result.append(routes)
            }
        }
        return result
    }
}

