/*
    Search Area:
        ------------------------------------
            [ Form                  ] 􀄬
            [ To                    ]
            | 􀝈 ? mins | 􀝢 ? mins  |
        ------------------------------------
 
    Search List:
        ------------------------------------
            􀯶  [ From                ]  􀆄
            􀋒 Your Location
            􀝓 ???
            􀝈 ???
        ------------------------------------
 
    􀄬: arrow.up.arrow.down
    􀝈: bus
    􀝢: figure.walk
    􀯶: chevron.backward
    􀆄: xmark
    􀋒: location.fill
    􀝓: building.2.fill
*/


import Foundation
import SwiftUI

let INF: Double = 99999

enum TransMode {
    case bus
    case foot
}

// To control which page to show
struct SearchView: View {
    
    // data used to do route planning
    @ObservedObject var locationGetter: LocationGetterModel
    @State var locations: [Location]
    @State var startLoc: Location? = nil
    @State var endLoc: Location? = nil
    @State var routes: [Route]
    @State var buses: [Bus]
    
    // result of route planning
    @Binding var plans: [Plan]
    @Binding var chosenPlan: Plan?
    
    // decide which plan to display
    @Binding var mode: TransMode
    
    // height of plan view
    @Binding var lastHeight: CGFloat
    @Binding var height: CGFloat
    
    // show SearchList
    @State var showStartList = false
    @State var showEndList = false
    
    var body: some View {
        if showStartList {
            // Page 1: search starting point
            SearchList(placeholder: "From", keyword: startLoc == nil ? "" : startLoc!.name_en, locations: locations, showCurrent: endLoc == nil || endLoc!._id != "current", location: $startLoc, showList: $showStartList)
        } else if showEndList {
            // Page 2: search ending point
            SearchList(placeholder: "To", keyword: endLoc == nil ? "" : endLoc!.name_en, locations: locations, showCurrent: startLoc == nil || startLoc!._id != "current", location: $endLoc, showList: $showEndList)
        } else {
            // Page 3: search box
            SearchArea(locations: locations, startLoc: $startLoc, endLoc: $endLoc, routes: routes, buses: buses, current: $locationGetter.current, plans: $plans, chosenPlan: $chosenPlan, showStartList: $showStartList, showEndList: $showEndList, mode: $mode)
                .offset(y: height > smallH ? (smallH - height) * 2 : 0)
                .onAppear {
                    if startLoc != nil && endLoc != nil {
                        lastHeight = smallH
                        height = smallH
                    }
                }
        }
    }
}

// Search bar: to do route planning
struct SearchArea: View {

    // input for RP
    @State var locations: [Location]
    @Binding var startLoc: Location?
    @Binding var endLoc: Location?
    @State var routes: [Route]
    @State var buses: [Bus]
    @Binding var current: Coor3D

    // output of RP
    @Binding var plans: [Plan]
    @Binding var chosenPlan: Plan?
    
    // show searchList
    @Binding var showStartList: Bool
    @Binding var showEndList: Bool
    
    // other data
    @Binding var mode: TransMode
    @State var angle = 0.0 // animation for 􀄬
    
    var body: some View {
        // find min time for both mode
        var footTime = INF
        var busTime = INF
        for plan in plans {
            if plan.type == 0 && plan.time < footTime {
                footTime = plan.time
            }
            if plan.type == 1 && plan.time < busTime {
                busTime = plan.time
            }
        }
        
        return GeometryReader { geometery in
            VStack {
                VStack(spacing: 20) {
                    // safe area
                    Color.white.frame(width: geometery.size.width, height: geometery.safeAreaInsets.bottom, alignment: .center)
                    
                    // search box
                    HStack {
                        VStack(spacing: 12) {
                            Text(startLoc == nil ? "From" : startLoc!.name_en)
                                .foregroundColor(startLoc == nil ? .gray : .black)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .padding()
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 0.8))
                                .onTapGesture { showStartList = true }
                            Text(endLoc == nil ? "To" : endLoc!.name_en)
                                .foregroundColor(endLoc == nil ? .gray : .black)
                                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                                .contentShape(Rectangle())
                                .padding()
                                .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 0.8))
                                .onTapGesture { showEndList = true }
                        }
                        Image(systemName: "arrow.up.arrow.down")
                            .imageScale(.large)
                            .rotationEffect(.degrees(angle))
                            .animation(Animation.easeInOut(duration: 0.1))
                            .padding(.leading)
                            .onTapGesture {
                                angle += 180
                                let tmp = startLoc
                                startLoc = endLoc
                                endLoc = tmp
                                RP()
                            }
                    }
                    .padding(.top)
                    .padding(.horizontal)

                    // select mode
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
                                // chosenPlan = plans.first(where: {$0.type == 1})
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
                                // chosenPlan = plans.first(where: {$0.type == 0})
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.bottom)
                    
                }
                
                .frame(width: geometery.size.width)
                .background(Color.white)
                .clipped()
                .shadow(radius: 4)
                .onAppear() {
                    RP()
                }
            }
            Spacer()
            
        }.edgesIgnoringSafeArea(.top)
    }
    private func RP() {
        // Step 1: Clear result
        plans = []
        
        // Step 2: Deal with nil input
        if startLoc == nil || endLoc == nil { return }
        
        // Step 3: Deal with current location
        let curLoc = Location(_id: "current", name_en: "Your Location", latitude: current.latitude, longitude: current.longitude, altitude: current.altitude, type: 0)
        var newLocs = locations
        var newRoutes: [Route] = []
        if startLoc!._id == "current" || endLoc!._id == "current" {
            if startLoc!._id == "current" { startLoc = curLoc }
            if endLoc!._id == "current" { endLoc = curLoc }
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
        processPlans()
        
        
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
    
    private func processPlans() {
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
    }
    
}

struct SearchList: View {
    // search box
    @State var placeholder: String
    @State var keyword: String
    
    // location list
    @State var locations: [Location]
    @State var showCurrent: Bool
    
    // chosen location
    @Binding var location: Location?

    // show itself
    @Binding var showList: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // white background
                Rectangle()
                    .foregroundColor(.white)
                    .frame(minWidth: geometry.size.width, maxWidth: .infinity, minHeight: geometry.size.height, maxHeight: .infinity, alignment: .center)
                    .ignoresSafeArea(.all)
                
                VStack(spacing: 0) {
                    // text field
                    VStack(spacing: 0) {
                        HStack(spacing: 20) {
                            Image(systemName: "chevron.backward")
                                .imageScale(.large)
                                .onTapGesture { showList = false }
                            TextField(placeholder, text: $keyword)
                            if keyword != "" {
                                Image(systemName: "xmark")
                                    .imageScale(.large)
                                    .onTapGesture { keyword = "" }
                            }
                        }
                        .padding()
                        .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray, lineWidth: 0.8))
                        .padding()
                        // shadow
                        Rectangle()
                            .foregroundColor(.white)
                            .frame(width: UIScreen.main.bounds.width, height: 2)
                            .shadow(color: Color.gray.opacity(0.3), radius: 2, x: 0, y: 2)
                    }.padding(.bottom, 6)
                    
                    // list
                    ScrollView {
                        VStack(spacing: 0) {
                            // current location
                            showCurrent ? Button(action: {
                                self.location = Location(_id: "current", name_en: "Your Location", latitude: -1, longitude: -1, altitude: -1, type: 0)
                                showList = false
                            }) {
                                HStack(spacing: 20) {
                                    Image(systemName: "location.fill")
                                        .imageScale(.large)
                                        .foregroundColor(Color.blue)
                                        
                                    Text("Your Location")
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .contentShape(Rectangle())
                            }.buttonStyle(MyButtonStyle()) : nil
                            
                            showCurrent ? Divider().padding(.horizontal) : nil
                            // other locations
                            ForEach(locations) { location in
                                if keyword == "" || location.name_en.lowercased().contains(keyword.lowercased()) {
                                    Button(action: {
                                        self.location = location
                                        showList = false
                                    }) {
                                        HStack(spacing: 20) {
                                            if location.type == 0 {
                                                Image(systemName: "building.2.fill")
                                                    .imageScale(.large)
                                                    .foregroundColor(CUPurple)
                                            } else if location.type == 1 {
                                                Image(systemName: "bus")
                                                    .imageScale(.large)
                                                    .foregroundColor(CUYellow)
                                            }
                                            Text(location.name_en)
                                            Spacer()
                                        }
                                        .padding(.horizontal)
                                        .contentShape(Rectangle())
                                    }.buttonStyle(MyButtonStyle())
                                    Divider().padding(.horizontal)
                                }
                            }
                        }
                    }
                    // end of scrollview
                }
            }
        }
    }
}
