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
    
    // height of plan view
    @Binding var lastHeight: CGFloat
    @Binding var height: CGFloat
    
    @Binding var showStartList: Bool
    @Binding var showEndList: Bool
    
    var body: some View {
        if showStartList {
            // Page 1: search starting point
            SearchList(locations: locations, placeholder: "From", locationName: $startName, locationId: $startId, keyword: startName, showList: $showStartList)
                .onAppear() {
                    height = 0
                    lastHeight = 0
                }
        } else if showEndList {
            // Page 2: search ending point
            SearchList(locations: locations, placeholder: "To", locationName: $endName, locationId: $endId, keyword: endName, showList: $showEndList)
                .onAppear() {
                    height = 0
                    lastHeight = 0
                }
        } else {
            // Page 3: search box
            let offset = smallH - height >= 0 ? 0 : smallH - height
            ZStack {
                // blank
                Rectangle()
                    .frame(height: SCHeight * 0.3)
                    .foregroundColor(.white)
                    .offset(y: -SCHeight * 0.5 + offset).animation(Animation.easeOut)
                VStack(spacing: 0) {
                    SearchArea(locations: locations, routes: routes, plans: $plans, locationGetter: locationGetter, startName: startName, endName: endName, startId: startId, endId: endId, mode: $mode, lastHeight: $lastHeight, height: $height, showStartList: $showStartList, showEndList: $showEndList)
                    Spacer()
                }.offset(y: offset).animation(Animation.easeOut)
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
    
    // height of plan view
    @Binding var lastHeight: CGFloat
    @Binding var height: CGFloat
    
    @Binding var showStartList: Bool
    @Binding var showEndList: Bool

    // animation for 􀄬
    @State var angle = 0.0
    
    var body: some View {
        VStack(spacing: 0) {
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
                    .rotationEffect(.degrees(angle))
                    .animation(Animation.easeInOut(duration: 0.1))
                    .padding(.leading)
                    .onTapGesture {
                        angle = 180 - angle
                        // swap
                        var tmp = startName
                        startName = endName
                        endName = tmp
                        tmp = startId
                        startId = endId
                        endId = tmp
                        dij()
                    } 
            }.padding(.horizontal, 30).padding(.top)
            // select mode
            ModeSelectBar(plans: $plans, mode: $mode, lastHeight: $lastHeight, height: $height)
                .padding(.horizontal, 30).padding(.top)
            
            // shadow
            Rectangle()
                .foregroundColor(.white)
                .frame(width: SCWidth, height: 10)
                .shadow(color: Color.gray.opacity(0.3), radius: 2, x: 0, y: 4)
        }
        .background(Color.white)
        .onAppear() {
            if startId != "" && endId != "" {
                height = smallH
                lastHeight = smallH
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

struct ModeSelectBar: View {
    @Binding var plans: [Plan]
    @Binding var mode: TransMode
    // height of plan view
    @Binding var lastHeight: CGFloat
    @Binding var height: CGFloat
    
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
        return ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 30) {
                HStack {
                    Image(systemName: "bus").foregroundColor(Color.black.opacity(0.7))
                    if lastHeight != 0 {
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
                    if lastHeight != 0 {
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
                    .frame(width: SCWidth, height: 2)
                    .shadow(color: Color.gray.opacity(0.3), radius: 2, x: 0, y: 2)
            }.padding(.bottom, 6)
            
            ScrollView {
                VStack(spacing: 0) {
                    // current location
                    Button(action: {
                        locationName = "Your Location"
                        locationId = "current"
                        showList = false
                    }) {
                        HStack(spacing: 20) {
                            Image(systemName: "location.fill")
                                .imageScale(.large)
                                .foregroundColor(Color.blue)
                                
                            Text("Your Location")
                            Spacer()
                        }
                    }.buttonStyle(MyButtonStyle())
                    Divider()
                    // other locations
                    ForEach(locations) { location in
                        if keyword == "" || location.name_en.lowercased().contains(keyword.lowercased()) {
                            SearchOption(name: $locationName, id: $locationId, location: location, showList: $showList)
                            Divider()
                        }
                    }
                }.padding(.horizontal)
            }
        }.background(Color.white)
    }
}

struct SearchOption: View {
    @Binding var name: String
    @Binding var id: String
    @State var location: Location
    @Binding var showList: Bool
    
    var body: some View {
        Button(action: {
            name = location.name_en
            id = location.id
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
        }.buttonStyle(MyButtonStyle())
    }
}
