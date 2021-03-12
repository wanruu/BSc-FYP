import SwiftUI

struct NaviPage: View {
    // @EnvironmentObject var locationModel: LocationModel
    @Environment(\.colorScheme) var colorScheme
    
    // input data
    @State var locations: [Location]
    @State var buses: [Bus]
    @State var routesOnFoot: [Route]
    @State var routesByBus: [Route]
    
    // user selected
    @State var startLoc: Location? = nil
    @State var endLoc: Location? = nil
    @State var planType: PlanType = .byBus
    
    // result
    @State var isRoutePlanning = false
    @State var plansByBus: [Plan] = []
    @State var plansOnFoot: [Plan] = []
    @State var selectedPlan: Plan? = nil
    @State var minTimeByBus: Double = .infinity // min
    @State var minTimeOnFoot: Double = .infinity

    @Binding var showing: Bool
    @State var showPlans: Bool = false
    
    var body: some View {
        ZStack {
            NaviMapView(startLoc: $startLoc, endLoc: $endLoc, selectedPlan: $selectedPlan)
                .ignoresSafeArea(.all)
            TopBottomView(showBottom: $showPlans, top: {
                SearchAreaView(locations: locations, startLoc: $startLoc, endLoc: $endLoc, planType: $planType, minTimeByBus: $minTimeByBus, minTimeOnFoot: $minTimeOnFoot, showing: $showing)
            }, bottom: {
                if planType == .byBus {
                    PlansByBusView(plansByBus: $plansByBus, selectedPlan: $selectedPlan)
                } else {
                    PlansOnFootView(plansOnFoot: $plansOnFoot, selectedPlan: $selectedPlan)
                }
            })
            
            isRoutePlanning ?
            ProgressView("Processing", value: 0)
                .progressViewStyle(CircularProgressViewStyle())
                .frame(width: UIScreen.main.bounds.width * 0.7, height: UIScreen.main.bounds.width * 0.2)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(colorScheme == .light ? Color.white : Color.black).shadow(radius: 5)
                )
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.gray.opacity(0.2))
                .ignoresSafeArea(.all) : nil
        }
        .navigationBarHidden(true)
        .onChange(of: startLoc) { _ in
            let queue = DispatchQueue(label: "route planning")
            queue.async {
                isRoutePlanning = true
                RP()
                isRoutePlanning = false
            }
        }
        .onChange(of: endLoc) { _ in
            let queue = DispatchQueue(label: "route planning")
            queue.async {
                isRoutePlanning = true
                RP()
                isRoutePlanning = false
            }
        }
        .onAppear {
            let queue = DispatchQueue(label: "route planning")
            queue.async {
                isRoutePlanning = true
                RP()
                isRoutePlanning = false
            }
        }
    }
    
    private func RP() {
        // Step 1: Clear result
        showPlans = false
        plansOnFoot.removeAll()
        plansByBus.removeAll()
        selectedPlan = nil
        
        // Step 2: Deal with nil input
        if startLoc == nil || endLoc == nil {
            return
        }
        
        // Step 3: Consider current location and generate new data for processing
        var newLocs = locations
        var newRoutesOnFoot: [Route] = []
        
        if startLoc!.type == .user || endLoc!.type == .user {
            let curLoc: Location
            if startLoc!.type == .user {
                curLoc = startLoc!
            } else {
                curLoc = endLoc!
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
        var isBusChecked: [String: Bool] = [:]
        for bus in buses {
            isBusChecked[bus.id] = false
        }
        checkRoutes(locations: newLocs, routesOnFoot: newRoutesOnFoot, curEndLoc: startLoc!, curRoutes: [], curWalkDist: 0, isBusChecked: isBusChecked, maxWalkDist: 500)
        
        showPlans = true
    }
    
    // DFS recursion for find plan by bus
    private func checkRoutes(locations: [Location], routesOnFoot: [Route], curEndLoc: Location, curRoutes: [Route], curWalkDist: Double, isBusChecked: [String: Bool], maxWalkDist: Double) {
        
        let busCount = isBusChecked.filter({ $0.value }).count
        if busCount > 2 || (busCount != 0 && curWalkDist > maxWalkDist) {
            return
        }
        
        // 1. Found way to endLoc
        if curEndLoc == endLoc {
            var dist: Double = 0
            var type: PlanType = .onFoot
            for route in curRoutes {
                dist += route.dist
                if route.type == .byBus {
                    type = .byBus
                }
            }
            // TODO: calculate time & ascent
            
            let plan = Plan(startLoc: startLoc, endLoc: curEndLoc, routes: curRoutes, dist: dist, time: 0, ascent: 0, type: type)
            if type == .onFoot {
                plansOnFoot.append(plan)
                plansOnFoot.sort(by: { $0.dist < $1.dist})
            } else if type == .byBus {
                plansByBus.append(plan)
                plansByBus.sort(by: { $0.dist < $1.dist })
            }
            return
        }
        
        // 2. check next possible route
        // check bus
        for bus in buses { // for each bus
            
            // whether this bus is checked or not
            if isBusChecked[bus.id] == true {
                continue
            }
            var isBusChecked = isBusChecked
            isBusChecked[bus.id] = true
            
            // find indexes of cur end location in its stop
            var indexes: [Int] = []
            for i in 0..<bus.stops.count {
                if bus.stops[i] == curEndLoc {
                    indexes.append(i)
                }
            }
            
            // consider stops between each two indexes
            if !indexes.isEmpty {
                indexes.append(bus.stops.count) // append end index of bus stops
                
                for i in 0..<indexes.count-1 {
                    let thisIndex = indexes[i] // startStop
                    let nextIndex = indexes[i+1] // max index of EndStop - 1
                    var newRoutes: [Route] = []
                    
                    for j in thisIndex+1..<nextIndex { // for each stop between two indexes, append routes
                        if var route = routesByBus.first(where: { $0.startLoc == bus.stops[j-1] && $0.endLoc == bus.stops[j] }) {
                            route.id = UUID().uuidString
                            route.bus = bus
                            route.type = .byBus
                            newRoutes.append(route)
                        }
                        
                        if !isBack(routes: curRoutes, loc: bus.stops[j]) {
                            checkRoutes(locations: locations, routesOnFoot: routesOnFoot, curEndLoc: bus.stops[j], curRoutes: curRoutes + newRoutes, curWalkDist: curWalkDist, isBusChecked: isBusChecked, maxWalkDist: maxWalkDist)
                        }
                    }
                    
                }
            }
        }
        
        // check route on foot
        for route in routesOnFoot {
            if route.startLoc == curEndLoc && !isBack(routes: curRoutes, newRoute: route) {
                checkRoutes(locations: locations, routesOnFoot: routesOnFoot, curEndLoc: route.endLoc, curRoutes: curRoutes + [route], curWalkDist: curWalkDist + route.dist, isBusChecked: isBusChecked, maxWalkDist: maxWalkDist)
            } else if route.endLoc == curEndLoc {
                let newRoute = Route(id: UUID().uuidString, startLoc: route.endLoc, endLoc: route.startLoc, points: route.points.reversed(), dist: route.dist, type: route.type)
                if !isBack(routes: curRoutes, newRoute: newRoute) {
                    checkRoutes(locations: locations, routesOnFoot: routesOnFoot, curEndLoc: route.startLoc, curRoutes: curRoutes + [newRoute], curWalkDist: curWalkDist + route.dist, isBusChecked: isBusChecked, maxWalkDist: maxWalkDist)
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
                if route.type == .onFoot && route.points.contains(newPoint) {
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
    
    private func isBack(routes: [Route], loc: Location) -> Bool {
        for route in routes {
            if route.startLoc == loc {
                return true
            }
        }
        return false
    }

}

