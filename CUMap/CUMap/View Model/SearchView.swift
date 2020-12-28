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
*/

/*
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

let INF: Double = 9999999

enum TransMode {
    case bus
    case foot
}

// To control which page to show
struct SearchView: View {
    @State var locations: [Location]
    @State var routes: [Route]
    @Binding var plans: [Plan]
    @ObservedObject var locationGetter: LocationGetterModel
    
    @State var startName = ""
    @State var endName = ""
    @State var startId = ""
    @State var endId = ""
    
    @Binding var mode: TransMode
    
    @State var showStartList = false
    @State var showEndList = false
    @Binding var showPlans: Bool
    
    var body: some View {
        if showStartList {
            // Page 1: search starting point
            SearchList(locations: locations, placeholder: "From", locationName: $startName, locationId: $startId, keyword: startName, showList: $showStartList)
                .onAppear() {
                    showPlans = false
                }
        } else if showEndList {
            // Page 2: search ending point
            SearchList(locations: locations, placeholder: "To", locationName: $endName, locationId: $endId, keyword: endName, showList: $showEndList)
                .onAppear() {
                    showPlans = false
                }
        } else {
            // Page 3: search box
            VStack {
                SearchArea(locations: locations, routes: routes, plans: $plans, locationGetter: locationGetter, startName: startName, endName: endName, startId: startId, endId: endId, mode: $mode, showStartList: $showStartList, showEndList: $showEndList, showPlans: $showPlans)
                Spacer()
            }
        }
    }
}

// Search bar: to do route planning
struct SearchArea: View {
    @State var locations: [Location]
    @State var routes: [Route]
    @Binding var plans: [Plan]
    @ObservedObject var locationGetter: LocationGetterModel
    
    @State var startName: String
    @State var endName: String
    @State var startId: String
    @State var endId: String
    
    @Binding var mode: TransMode
    
    @Binding var showStartList: Bool
    @Binding var showEndList: Bool
    @Binding var showPlans: Bool
    
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
        
        return VStack(spacing: 15) {
            // search box
            HStack {
                VStack {
                    TextField("From", text: $startName)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 0.8))
                        .onTapGesture { showStartList = true }
                    TextField("To", text: $endName)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 0.8))
                        .onTapGesture { showEndList = true }
                }
                Image(systemName: "arrow.up.arrow.down")
                    .imageScale(.large)
                    .padding()
                    .onTapGesture {
                        // swap
                        var tmp = startName
                        startName = endName
                        endName = tmp
                        tmp = startId
                        startId = endId
                        endId = tmp
                        dij()
                    } // TODO: add rotate animation
            }
            // select mode
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 30) {
                    HStack {
                        Image(systemName: "bus").foregroundColor(Color.black.opacity(0.7))
                        busTime == INF ? Text("—") : Text("\(Int(busTime / 60)) min")
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(mode == .bus ? CUPurple.opacity(0.2) : nil)
                    .cornerRadius(20)
                    .onTapGesture {
                        mode = .bus
                    }
                    
                    HStack {
                        Image(systemName: "figure.walk").foregroundColor(Color.black.opacity(0.7))
                        footTime == INF ? Text("—") : Text("\(Int(footTime) / 60) min")
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(mode == .foot ? CUPurple.opacity(0.2) : nil)
                    .cornerRadius(20)
                    .onTapGesture {
                        mode = .foot
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
        .onAppear() {
            if startId != "" && endId != "" {
                showPlans = true
            }
            dij()
        }
    }
    
    private func dij() {
        // TODO: deal with current location
        if startId == "" || endId == "" {
            return
        }
        // Step 1: clean up result
        plans = []
        
        // Step 2: initialize minDist & vertex set & queue
        let startIndex = indexOf(id: startId)
        let endIndex = indexOf(id: endId)
        
        var minDist = [Plan](repeating: Plan(startId: startId, endId: endId, routes: [], dist: INF, time: INF, type: 0), count: locations.count) // distance from start location to every location
        var checked = [Bool](repeating: false, count: locations.count)
        minDist[startIndex].dist = 0
        minDist[startIndex].time = 0
        
        // Step 3: start
        while checked.filter({$0 == true}).count != checked.count { // not all have been checked
            // find the index of min dist who hasn't been checked
            var cur = -1
            var min = INF + 1.0
            for i in 0..<checked.count {
                if !checked[i] && minDist[i].dist < min {
                    cur = i
                    min = minDist[i].dist
                }
            }
            
            for route in routes {
                if route.startId == locations[cur].id {
                    let next = indexOf(id: route.endId)
                    if minDist[next].dist > minDist[cur].dist + route.dist { // update
                        minDist[next].dist = minDist[cur].dist + route.dist
                        minDist[next].routes = minDist[cur].routes + [route]
                        let time = route.type == 0 ? route.dist / footSpeed : route.dist / busSpeed
                        minDist[next].time = minDist[cur].time + time
                    }
                } else if route.endId == locations[cur].id {
                    let next = indexOf(id: route.startId)
                    if minDist[next].dist > minDist[cur].dist + route.dist { // update
                        var points = route.points
                        points.reverse()
                        minDist[next].dist = minDist[cur].dist + route.dist
                        minDist[next].routes = minDist[cur].routes + [Route(id: route.id, startId: route.endId, endId: route.startId, points: points, dist: route.dist, type: route.type)]
                        let time = route.type == 0 ? route.dist / footSpeed : route.dist / busSpeed
                        minDist[next].time = minDist[cur].time + time
                    }
                }
            }
            checked[cur] = true
        }
        
        // Step 4: find the result
        if minDist[endIndex].routes.count > 1 {
            plans.append(minDist[endIndex])
        }
    }
    
    private func indexOf(id: String) -> Int {
        for i in 0..<locations.count {
            if locations[i].id == id {
                return i
            }
        }
        return -1
    }
    
}

struct SearchList: View {
    @State var locations: [Location]
    
    var placeholder: String
    
    @Binding var locationName: String
    @Binding var locationId: String
    
    @State var keyword: String
    
    @Binding var showList: Bool
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "chevron.backward")
                    .imageScale(.large)
                    .padding(.trailing)
                    .onTapGesture {
                        showList = false
                    }
                TextField(placeholder, text: $keyword)
                if keyword != "" {
                    Image(systemName: "xmark")
                        .imageScale(.large)
                        .padding(.leading)
                        .onTapGesture {
                            keyword = ""
                        }
                }
            }
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray, lineWidth: 0.8))
            .padding()

            List {
                // current location
                Button(action: {
                    locationName = "Your Location"
                    locationId = "current"
                    showList = false
                }) {
                    HStack {
                        Image(systemName: "location.fill")
                            .imageScale(.large)
                            .foregroundColor(Color.blue)
                            .padding(.trailing)
                        Text("Your Location")
                    }
                }
                
                // other locations
                ForEach(locations) { location in
                    if keyword == "" || location.name_en.lowercased().contains(keyword.lowercased()) {
                        Button(action: {
                            locationName = location.name_en
                            locationId = location.id
                            showList = false
                        }) {
                            HStack {
                                if location.type == 0 {
                                    Image(systemName: "building.2.fill")
                                        .imageScale(.large)
                                        .foregroundColor(CUPurple)
                                        .padding(.trailing)
                                } else if location.type == 1 {
                                    Image(systemName: "bus")
                                        .imageScale(.large)
                                        .foregroundColor(CUYellow)
                                        .padding(.trailing)
                                }
                                Text(location.name_en)
                            }
                        }
                    }
                }
            }
            
        }.background(Color.white)
    }
}

// classify search results into by bus or on foot
func classify(plans: [[Route]]) -> ([[Route]], [[Route]]) { // [foot plan], [bus plan]
    var foot: [[Route]] = []
    var bus: [[Route]] = []
    
    for plan in plans {
        if plan.filter({$0.type == 1}).count > 0 {
            bus.append(plan)
        } else {
            foot.append(plan)
        }
    }
    return (foot, bus)
}

func estimateTime(plan: [Route]) -> Int { // min
    var time = 0.0
    for route in plan {
        if route.type == 0 {
            time += route.dist / footSpeed
        } else if route.type == 1 {
            time += route.dist / busSpeed
        }
    }
    return Int(time / 60)
}
