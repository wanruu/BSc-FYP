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
    @Binding var planIndex: Int
    
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
            SearchArea(locations: locations, startLoc: $startLoc, endLoc: $endLoc, routes: routes, buses: buses, plans: $plans, planIndex: $planIndex, showStartList: $showStartList, showEndList: $showEndList, mode: $mode)
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

    // output of RP
    @Binding var plans: [Plan]
    @Binding var planIndex: Int
    
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
                                angle = 180 - angle
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
                                    busTime == INF ? Text("—") : Text("\(Int(busTime / 60)) min")
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(mode == .bus ? CUPurple.opacity(0.2) : nil)
                            .cornerRadius(20)
                            .onTapGesture { mode = .bus }
                            HStack {
                                Image(systemName: "figure.walk").foregroundColor(Color.black.opacity(0.7))
                                if startLoc != nil && endLoc != nil {
                                    footTime == INF ? Text("—") : Text("\(Int(footTime) / 60) min")
                                }
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 5)
                            .background(mode == .foot ? CUPurple.opacity(0.2) : nil)
                            .cornerRadius(20)
                            .onTapGesture { mode = .foot }
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
        // Clear result
        plans = []
        
        if startLoc == nil || endLoc == nil { return }
        
        // Deal with current location
        var newLocs = locations
        var newRoutes = routes
        if startLoc!._id == "current" {
            newLocs.append(startLoc!)
        } else if endLoc!._id == "current" {
            newLocs.append(endLoc!)
        }
        // self.location = Location(_id: "current", name_en: "Your Location", latitude: locationGetter.current.latitude, longitude: locationGetter.current.longitude, altitude: locationGetter.current.altitude, type: 0)
        
        let plan1 = RPMinDist(locations: locations, routes: routes, startLoc: startLoc!, endLoc: endLoc!)
        if plan1 != nil {
            plans.append(plan1!)
        }
        let plan2 = RPMinTime(locations: locations, routes: routes, startLoc: startLoc!, endLoc: endLoc!)
        if plan2 != nil {
            plans.append(plan2!)
        }
        print(plans.count)
        
        planIndex = 0
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
                                }.padding(.horizontal)
                            }.buttonStyle(MyButtonStyle()) : nil
                            
                            Divider().padding(.horizontal)
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
                                        }.padding(.horizontal)
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


// MARK: - function for route planning
func RPMinDist(locations: [Location], routes: [Route], startLoc: Location, endLoc: Location) -> Plan? {
    // Step 1: preprocessing
    var plan: Plan? = nil
    var plans = [Plan](repeating: Plan(startLoc: startLoc, endLoc: endLoc, routes: [], dist: INF, time: INF, ascent: 0, type: 0), count: locations.count) // plan from startLoc to any other locations
    
    var checked = [Bool](repeating: false, count: locations.count) // at beginning, all locations are not checked
    
    // Step 2: set dist and time to 0 for startLoc
    let startIndex = locations.firstIndex(of: startLoc)!
    let endIndex = locations.firstIndex(of: endLoc)!
    plans[startIndex].dist = 0
    
    // Step 3: loop to check
    while checked.filter({$0 == true}).count != checked.count { // not all have been checked
        // find location with min dist so far who hasn't been checked
        var index = -1
        var minDist = INF + 1.0
        for i in 0..<checked.count {
            if !checked[i] && plans[i].dist < minDist {
                index = i
                minDist = plans[i].dist
            }
        }
        let curLoc = locations[index]
        if index == endIndex {
            break
        }
        
        // find all route related to curLoc and update statistics
        for route in routes {
            if route.startLoc.id == curLoc.id { // if curLoc is startLoc of the route
                let endLocIndex = locations.firstIndex(of: route.endLoc)!
                if plans[endLocIndex].dist > plans[index].dist + route.dist {
                    plans[endLocIndex].dist = plans[index].dist + route.dist
                    plans[endLocIndex].routes = plans[index].routes + [route]
                }
            } else if route.endLoc.id == curLoc.id { // if curLoc is endLoc of the route
                let startLocIndex = locations.firstIndex(of: route.startLoc)!
                if plans[startLocIndex].dist > plans[index].dist + route.dist {
                    var points = route.points
                    points.reverse()
                    plans[startLocIndex].dist = plans[index].dist + route.dist
                    plans[startLocIndex].routes = plans[index].routes + [Route(_id: route.id, startLoc: route.endLoc, endLoc: route.startLoc, points: points, dist: route.dist, type: route.type)]
                }
            }
        }
        checked[index] = true
    }
    // Step 4: find the result
    if plans[endIndex].routes.count > 1 {
        plan = plans[endIndex]
    }
    
    
    if plan != nil {
        var totalDist = 0.0 // meters
        var totalTime = 0.0 // seconds
        
        // TODO: calculate ascent
        var ascent: Double = 0
        
        for route in plan!.routes {
            totalDist += route.dist
            if route.type == 0 {
                totalTime += route.dist / footSpeed
            } else {
                totalTime += route.dist / busSpeed
            }
        }

        plan!.dist = totalDist
        plan!.time = totalTime
        plan!.ascent = ascent
    }
    
    
    return plan
}


func RPMinTime(locations: [Location], routes: [Route], startLoc: Location, endLoc: Location) -> Plan? {
    var plan: Plan? = nil
    
    // Step 1: preprocessing
    var plans = [Plan](repeating: Plan(startLoc: startLoc, endLoc: endLoc, routes: [], dist: INF, time: INF, ascent: 0, type: 0), count: locations.count) // plan from startLoc to any other locations
    
    var checked = [Bool](repeating: false, count: locations.count) // at beginning, all locations are not checked
    
    // Step 2: set dist and time to 0 for startLoc
    let startIndex = locations.firstIndex(of: startLoc)!
    let endIndex = locations.firstIndex(of: endLoc)!
    plans[startIndex].time = 0
    plans[startIndex].dist = 0
    
    // Step 3: start
    while checked.filter({$0 == true}).count != checked.count { // not all have been checked
        // find the index of min dist who hasn't been checked
        var index = -1
        var minTime = INF + 1.0
        for i in 0..<checked.count {
            if !checked[i] && plans[i].time < minTime {
                index = i
                minTime = plans[i].time
            }
        }
        let curLoc = locations[index]
        if index == endIndex {
            break
        }
        
        for route in routes {
            let time = route.type == 0 ? route.dist / footSpeed : route.dist / busSpeed

            if route.startLoc.id == curLoc.id {
                let endLocIndex = locations.firstIndex(of: route.endLoc)!
                if plans[endLocIndex].time > plans[index].time + time {
                    plans[endLocIndex].time = plans[index].time + time
                    plans[endLocIndex].dist = plans[index].dist + route.dist
                    plans[endLocIndex].routes = plans[index].routes + [route]
                }
            } else if route.endLoc.id == curLoc.id {
                
                let startLocIndex = locations.firstIndex(of: route.startLoc)!
                if plans[startLocIndex].time > plans[index].time + time {
                    var points = route.points
                    points.reverse()
                    plans[startLocIndex].dist = plans[index].dist + route.dist
                    plans[startLocIndex].time = plans[index].time + time
                    plans[startLocIndex].routes = plans[index].routes + [Route(_id: route.id, startLoc: route.endLoc, endLoc: route.startLoc, points: points, dist: route.dist, type: route.type)]
                }
            }
        }
        checked[index] = true
    }
    // Step 4: find the result
    if plans[endIndex].routes.count > 1 {
        plan = plans[endIndex]
    }
    
    return plan
}

