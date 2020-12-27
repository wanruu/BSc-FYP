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

struct SearchView: View {
    @Binding var locations: [Location]
    @Binding var routes: [Route]
    @Binding var plans: [[Route]]
    @ObservedObject var locationGetter: LocationGetterModel

    @State var startName = ""
    @State var endName = ""
    @State var startId = ""
    @State var endId = ""
    @State var showStartList = false
    @State var showEndList = false
    
    var body: some View {
        if showStartList {
            SearchList(locations: $locations, locationGetter: locationGetter, placeholder: "From", keyword: $startName, locationId: $startId, showList: $showStartList)
        } else if showEndList {
            SearchList(locations: $locations, locationGetter: locationGetter, placeholder: "To", keyword: $endName, locationId: $endId, showList: $showEndList)
        } else {
            VStack {
                SearchArea(showStartList: $showStartList, showEndList: $showEndList)
                Spacer()
            }
        }
    }
    
}
/*
struct SearchView: View {

    var body: some View {
        VStack {
            // search input area
            HStack {
                VStack {
                    // from
                    HStack {
                        showEndSearch ? nil : TextField("From", text: $start, onEditingChanged: { _ in })
                            .onTapGesture {
                                tmpKeyword = start
                                tmpType = startType
                                start = ""
                                startType = -1
                                showStartSearch = true
                                showEndSearch = false
                            }.textFieldStyle(RoundedBorderTextFieldStyle())
                        showStartSearch ? Button(action: {
                            showStartSearch = false
                            start = tmpKeyword
                            startType = tmpType
                            hideKeyboard()
                        }) { Text("Cancel")}.background(Color.white) : nil
                    }
                    // to
                    HStack {
                        showStartSearch ? nil : TextField("To", text: $end, onEditingChanged: { _ in })
                            .onTapGesture {
                                tmpKeyword = end
                                tmpType = endType
                                end = ""
                                endType = -1
                                showEndSearch = true
                                showStartSearch = false
                            }.textFieldStyle(RoundedBorderTextFieldStyle())
                        showEndSearch ? Button(action: {
                            showEndSearch = false
                            end = tmpKeyword
                            endType = tmpType
                            hideKeyboard()
                        }) { Text("Cancel")}.background(Color.white) : nil
                    }
                    
                }
                // search button
                showStartSearch || showEndSearch ? nil : Button(action: {
                    dij()
                }) {Text("Search")}.background(Color.white)
            }
            // search list
            showStartSearch ? List {
                ForEach(0 ..< locations.count) { index in
                    start == "" || locations[index].name_en.lowercased().contains(start.lowercased()) ?
                        Button(action: {
                            start = locations[index].name_en
                            startType = locations[index].type
                            showStartSearch = false
                            hideKeyboard()
                        }){ Text(locations[index].name_en) } : nil
                }
            } : nil
            showEndSearch ? List {
                ForEach(0 ..< locations.count) { index in
                    end == "" || locations[index].name_en.lowercased().contains(end.lowercased()) ?
                        Button(action: {
                            end = locations[index].name_en
                            endType = locations[index].type
                            showEndSearch = false
                            hideKeyboard()
                        } ){ Text(locations[index].name_en) } : nil
                }
            } : nil
            
            Spacer()
        }.padding()
    }
    private func dij() {
        // Step 1: clean up result
        result = []
        
        // Step 2: initialize minDist & vertex set & queue
        let startIndex = indexOf(id: startId)
        let endIndex = indexOf(id: endId)
        
        var minDist = [DijDist](repeating: DijDist(points: [], dist: INF), count: locations.count) // distance from start location to every location
        var checked = [Bool](repeating: false, count: locations.count)
        minDist[startIndex].dist = 0
        
        // Step 3: start
        while(checked.filter{$0 == true}.count != checked.count) { // not all have been checked
            // find the index of min dist who hasn't been checked
            var cur = -1
            var min = INF + 1.0
            for i in 0..<checked.count {
                if(!checked[i] && minDist[i].dist < min) {
                    cur = i
                    min = minDist[i].dist
                }
            }
            
            for route in routes {
                if(route.startId == locations[cur].id) {
                    let next = indexOf(id: route.endId)
                    if(minDist[next].dist > minDist[cur].dist + route.dist) { // update
                        minDist[next].dist = minDist[cur].dist + route.dist
                        var newPoints = minDist[cur].points
                        for i in 0..<route.points.count {
                            newPoints.append(route.points[i])
                        }
                        minDist[next].points = newPoints
                    }
                } else if(route.endId == locations[cur].id) {
                    let next = indexOf(id: route.startId)
                    if(minDist[next].dist > minDist[cur].dist + route.dist) { // update
                        minDist[next].dist = minDist[cur].dist + route.dist
                        var newPoints = minDist[cur].points
                        for i in 0..<route.points.count {
                            newPoints.append(route.points[route.points.count - 1 - i])
                        }
                        minDist[next].points = newPoints
                    }
                }
            }
            checked[cur] = true
        }
        
        // Step 4: find the result
        result = minDist[endIndex].points
    }
    private func indexOf(id: String) -> Int {
        for i in 0..<locations.count {
            if(locations[i].id == id) {
                return i
            }
        }
        return -1
    }
}

let INF: Double = 99999

struct DijDist {
    var points: [Coor3D]
    var dist: Double
}



*/

struct SearchArea: View {
    @Binding var showStartList: Bool
    @Binding var showEndList: Bool
    
    @State var startName = ""
    @State var endName = ""
    
    @State var startId = ""
    @State var endId = ""
    
    @State var showList = false
    var body: some View {
        HStack {
            VStack {
                TextField("From", text: $startName)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray, lineWidth: 0.8))
                    .onTapGesture {
                        showStartList = true
                    }

                TextField("To", text: $endName)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(16)
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray, lineWidth: 0.8))
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
        .padding()
    }
}

struct SearchList: View {
    @Binding var locations: [Location]
    @ObservedObject var locationGetter: LocationGetterModel
    var placeholder: String
    
    @Binding var keyword: String
    @Binding var locationId: String
    
    @Binding var showList: Bool
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "chevron.backward")
                    .imageScale(.large)
                    .padding(.trailing)
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
                        keyword = location.name_en
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

