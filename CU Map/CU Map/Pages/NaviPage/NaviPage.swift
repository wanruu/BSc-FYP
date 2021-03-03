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
    
    @State var showSearchArea = true
    
    var body: some View {
        VStack(spacing: 0) {
            if showSearchArea {
                SearchAreaView(locations: locations, startLoc: $startLoc, endLoc: $endLoc, planType: $planType, minTimeByBus: $minTimeByBus, minTimeOnFoot: $minTimeOnFoot)
                Divider()
            }
            ZStack {
                NaviMapView(startLoc: $startLoc, endLoc: $endLoc, selectedPlan: $selectedPlan)
                    .ignoresSafeArea(.all)
                if !showSearchArea {
                    VStack(alignment: .leading) {
                        Button(action: {
                            showSearchArea = true
                        }) {
                            Image(systemName: "chevron.backward.circle.fill").imageScale(.large)
                                .foregroundColor(.accentColor)
                        }
                        Spacer()
                    }
                }
            }
            
            if !showSearchArea {
                Divider()
                if planType == .byBus {
                
                } else if planType == .onFoot {
                    PlansOnFootView(plansOnFoot: $plansOnFoot, selectedPlan: $selectedPlan)
                }
            }

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
        checkRoutesOnFoot(locations: newLocs, routes: routesOnFoot, curStartLoc: nil, curEndLoc: nil, curRoutes: [])
        plansOnFoot.sort(by: { $0.dist < $1.dist})
        if planType == .onFoot {
            selectedPlan = plansOnFoot.first
        }
        
        print("=====")
        print(plansOnFoot.count)
        showSearchArea = false
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
}

