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

let INF: Double = 99999

struct DijDist {
    var routes: [Route]
    var dist: Double
}

enum TransMode {
    case bus
    case foot
}
struct SearchView: View {
    @State var locations: [Location]
    @State var routes: [Route]
    @State var plans: [[Route]]
    @ObservedObject var locationGetter: LocationGetterModel

    @State var mode: TransMode = .bus
    @State var startName = ""
    @State var endName = ""
    @State var startId = ""
    @State var endId = ""
    @State var showStartList = false
    @State var showEndList = false
    
    var body: some View {
        if showStartList {
            SearchList(locations: $locations, locationGetter: locationGetter, placeholder: "From", locationName: $startName, locationId: $startId, keyword: startName, showList: $showStartList)
        } else if showEndList {
            SearchList(locations: $locations, locationGetter: locationGetter, placeholder: "To", locationName: $endName, locationId: $endId, keyword: endName, showList: $showEndList)
        } else {
            VStack {
                SearchArea(startName: startName, endName: endName, startId: startId, endId: endId, busTime: 0, footTime: -1, showStartList: $showStartList, showEndList: $showEndList, mode: $mode)
                    .onAppear() {
                        if startId != "" && endId != "" {
                            dij()
                        }
                    }
                Spacer()
            }
        }
    }
    private func dij() {
        // Step 1: clean up result
        plans = []
        
        // Step 2: initialize minDist & vertex set & queue
        let startIndex = indexOf(id: startId)
        let endIndex = indexOf(id: endId)
        
        var minDist = [DijDist](repeating: DijDist(routes: [], dist: INF), count: locations.count) // distance from start location to every location
        var checked = [Bool](repeating: false, count: locations.count)
        minDist[startIndex].dist = 0
        
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
                    }
                } else if route.endId == locations[cur].id {
                    let next = indexOf(id: route.startId)
                    if minDist[next].dist > minDist[cur].dist + route.dist { // update
                        minDist[next].dist = minDist[cur].dist + route.dist
                        minDist[next].routes = minDist[cur].routes + [route]
                    }
                }
            }
            checked[cur] = true
        }
        
        // Step 4: find the result
        plans.append(minDist[endIndex].routes)
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

struct SearchArea: View {
    @State var startName: String
    @State var endName: String
    @State var startId: String
    @State var endId: String
    
    @State var busTime: Int
    @State var footTime: Int
    
    @Binding var showStartList: Bool
    @Binding var showEndList: Bool
    @Binding var mode: TransMode
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                VStack {
                    TextField("From", text: $startName)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 0.8))
                        .onTapGesture {
                            showStartList = true
                        }

                    TextField("To", text: $endName)
                        .padding(.horizontal)
                        .padding(.vertical, 10)
                        .overlay(RoundedRectangle(cornerRadius: 10).stroke(Color.gray, lineWidth: 0.8))
                        .onTapGesture {
                            showEndList = true
                        }
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
                    }
            }
            ScrollView(.horizontal, showsIndicators: true) {
                HStack(spacing: 30) {
                    HStack {
                        Image(systemName: "bus").foregroundColor(Color.black.opacity(0.7))
                        busTime == -1 ? Text("—") : Text("\(busTime) min")
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
                        footTime == -1 ? Text("—") : Text("\(footTime) min")
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
    }
}

struct SearchList: View {
    @Binding var locations: [Location]
    @ObservedObject var locationGetter: LocationGetterModel
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
                keyword == "" ? nil : Image(systemName: "xmark")
                    .imageScale(.large)
                    .padding(.leading)
                    .onTapGesture {
                        keyword = ""
                    }
            }
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray, lineWidth: 0.8))
            .padding()

            List {
                // current location
                Button(action: {
                    // TODO
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
                ForEach(locations) { location in keyword == "" || location.name_en.lowercased().contains(keyword.lowercased()) ?
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
                    } : nil
                }
            }
        }
        .background(Color.white)
    }
}

