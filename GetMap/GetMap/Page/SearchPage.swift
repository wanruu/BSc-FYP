import Foundation
import SwiftUI

struct SearchPage: View {
    @Binding var locations: [Location]
    @Binding var routes: [Route]
    
    @ObservedObject var locationGetter = LocationGetterModel()
    @State var startId = ""
    @State var endId = ""
    @State var result: [Coor3D] = []
    
    // gesture
    @State var offset = Offset(x: 0, y: 0)
    @State var scale = minZoomOut
    @State var lastOffset = Offset(x: 0, y: 0)
    @State var lastScale = minZoomOut
    var gesture: some Gesture {
        SimultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    var tmpScale = lastScale * value.magnitude
                    if(tmpScale < minZoomOut) {
                        tmpScale = minZoomOut
                    } else if(tmpScale > maxZoomIn) {
                        tmpScale = maxZoomIn
                    }
                    scale = tmpScale
                    offset = lastOffset * tmpScale / lastScale
                }
                .onEnded { _ in
                    lastScale = scale
                    lastOffset.x = offset.x
                    lastOffset.y = offset.y
                },
            DragGesture()
                .onChanged{ value in
                    offset.x = lastOffset.x + value.location.x - value.startLocation.x
                    offset.y = lastOffset.y + value.location.y - value.startLocation.y
                }
                .onEnded{ _ in
                    lastOffset.x = offset.x
                    lastOffset.y = offset.y
                }
            )
    }
    
    var body: some View {
        ZStack {
            ZStack {
                // background map
                Image("cuhk-campus-map")
                    .resizable()
                    .frame(width: 3200 * scale, height: 3200 * 25 / 20 * scale, alignment: .center)
                    .position(x: centerX + offset.x, y: centerY + offset.y)
                
                // result route
                Path { p in
                    for i in 0..<result.count {
                        let point = CGPoint(
                            x: centerX + CGFloat((result[i].longitude - centerLg)*lgScale*2) * scale + offset.x,
                            y: centerY + CGFloat((centerLa - result[i].latitude)*laScale*2) * scale + offset.y
                        )
                        if(i == 0) {
                            p.move(to: point)
                        } else {
                            p.addLine(to: point)
                        }
                    }
                }.stroke(Color.blue, style: StrokeStyle(lineWidth: 5, lineJoin: .round))
                
                // current location
                UserPoint(locationGetter: locationGetter, offset: $offset, scale: $scale)
            }
            .contentShape(Rectangle())
            .gesture(gesture)
            SearchArea(locations: $locations, routes: $routes, locationGetter: locationGetter, result: $result)
        }

    }
}

struct SearchArea: View {
    @Binding var locations: [Location]
    @Binding var routes: [Route]
    @ObservedObject var locationGetter: LocationGetterModel
    @Binding var result: [Coor3D]
    
    // search keyword
    @State var startName = ""
    @State var startId  = ""
    @State var endName = ""
    @State var endId = ""
    @State var showStartSearch = false
    @State var showEndSearch = false
    
    @State var tmpName = "" // for recovery
    @State var tmpId = ""

    var body: some View {
        VStack {
            // search input area
            HStack {
                VStack {
                    // from
                    HStack {
                        showStartSearch ?
                            Image(systemName: "chevron.backward")
                            .imageScale(.large)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                print("click")
                                showStartSearch = false
                                startName = tmpName
                                startId = tmpId
                                hideKeyboard()
                            } : nil
                        
                        showEndSearch ? nil : TextField("From", text: $startName)
                            .onTapGesture {
                                tmpName = startName
                                tmpId = startId
                                startName = ""
                                startId = ""
                                showStartSearch = true
                                showEndSearch = false
                            }.textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    // to
                    HStack {
                        showEndSearch ?
                            Image(systemName: "chevron.backward")
                            .imageScale(.large)
                            .contentShape(Rectangle())
                            .onTapGesture {
                                showEndSearch = false
                                endName = tmpName
                                endId = tmpId
                                hideKeyboard()
                            } : nil
                        
                        showStartSearch ? nil : TextField("To", text: $endName)
                            .onTapGesture {
                                tmpName = endName
                                tmpId = endId
                                endName = ""
                                endId = ""
                                showEndSearch = true
                                showStartSearch = false
                            }.textFieldStyle(RoundedBorderTextFieldStyle())
                    }
                    
                }
                // search button
                showStartSearch || showEndSearch ? nil : Button(action: {
                    dij()
                }) { Text("Search") }.background(Color.white).disabled(startName == "" || endName == "")
            }
            // search list
            showStartSearch ? List {
                ForEach(locations) { location in
                    startName == "" || location.name_en.lowercased().contains(startName.lowercased()) ?
                        Button(action: {
                            startName = location.name_en
                            startId = location.id
                            showStartSearch = false
                            hideKeyboard()
                        }){ Text(location.name_en) } : nil
                }
            } : nil
            showEndSearch ? List {
                ForEach(locations) { location in
                    endName == "" || location.name_en.lowercased().contains(endName.lowercased()) ?
                        Button(action: {
                            endName = location.name_en
                            endId = location.id
                            showEndSearch = false
                            hideKeyboard()
                        } ){ Text(location.name_en) } : nil
                }
            } : nil
        }
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

let INF = 99999.0

struct DijDist {
    var points: [Coor3D]
    var dist: Double
}
