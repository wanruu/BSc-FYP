//
//  - MapPage
//      - MapView
//          - Image
//          - ResultView
//      - SearchView
//
//

import Foundation
import SwiftUI

// MARK: - MapPage
struct MapPage: View {
    @Binding var locations: [Location]
    @Binding var paths: [PathBtwn]
    @ObservedObject var locationGetter: LocationGetterModel
    
    /* search result */
    @State var result: [Coor3D] = []
    
    var body: some View {
        ZStack(alignment: .bottom) {
            MapView(result: $result, locationGetter: locationGetter)
            SearchView(locations: $locations, paths: $paths, locationGetter: locationGetter, result: $result)
        }
    }
}

// MARK: - MapView
struct MapView: View {
    @Binding var result: [Coor3D]
    @ObservedObject var locationGetter: LocationGetterModel
    
    /* gesture */
    @State var lastOffset = Offset(x: 0, y: 0)
    @State var offset = Offset(x: 0, y: 0)
    @State var lastScale = initialZoom
    @State var scale = initialZoom
    
    var body: some View {
        ZStack {
            Image("cuhk-campus-map")
                .resizable()
                .frame(width: 3200 * scale, height: 3200 * 25 / 20 * scale, alignment: .center)
                .position(x: centerX + offset.x, y: centerY + offset.y)
            ResultView(path: $result, offset: $offset, scale: $scale)
            UserPoint(locationGetter: locationGetter, offset: $offset, scale: $scale)
        }
        .contentShape(Rectangle())
        .gesture(
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
        )
    }
}

struct ResultView: View {
    @Binding var path: [Coor3D]
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    var body: some View {
        Path { p in
            //for path in paths {
                for i in 0..<path.count {
                    let point = CGPoint(
                        x: centerX + CGFloat((path[i].longitude - centerLg)*lgScale*2) * scale + offset.x,
                        y: centerY + CGFloat((centerLa - path[i].latitude)*laScale*2) * scale + offset.y
                    )
                    if(i == 0) {
                        p.move(to: point)
                    } else {
                        p.addLine(to: point)
                    }
                }
            //}
        }.stroke(Color.blue, style: StrokeStyle(lineWidth: 5, lineJoin: .round))
    }
}

// MARK: - SearchView
struct SearchView: View {
    @Binding var locations: [Location]
    @Binding var paths: [PathBtwn]
    @ObservedObject var locationGetter: LocationGetterModel
    @Binding var result: [Coor3D]
    
    /* search keyword */
    @State var start: String = ""
    @State var startType: Int = -1
    @State var end: String = ""
    @State var endType: Int = -1
    @State var showStartSearch: Bool = false
    @State var showEndSearch: Bool = false
    
    @State var tmpKeyword: String = "" // for recovery
    @State var tmpType: Int = -1

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
        let startIndex = indexOf(name_en: start, type: startType)
        let endIndex = indexOf(name_en: end, type: endType)
        
        var minDist = [DijDist](repeating: DijDist(points: [], dist: INF), count: locations.count) // distance to every location
        var checked = [Bool](repeating: false, count: locations.count)
        minDist[startIndex].dist = 0
        
        // Step 3: start
        while(checked.filter{$0 == true}.count != checked.count) { // not all have been checked
            // find the index of min dist who hasn't been checked
            var cur: Int = -1
            var min: Double = INF + 1.0
            for i in 0..<checked.count {
                if(!checked[i] && minDist[i].dist < min) {
                    cur = i
                    min = minDist[i].dist
                }
            }
            
            for path in paths {
                if(path.start.name_en == locations[cur].name_en && path.start.type == locations[cur].type) {
                    let next = indexOf(name_en: path.end.name_en, type: path.end.type)
                    if(minDist[next].dist > minDist[cur].dist + path.dist) { // update
                        minDist[next].dist = minDist[cur].dist + path.dist
                        var newPoints = minDist[cur].points
                        for i in 0..<path.path.count {
                            newPoints.append(path.path[i])
                        }
                        minDist[next].points = newPoints
                    }
                } else if(path.end.name_en == locations[cur].name_en && path.end.type == locations[cur].type) {
                    let next = indexOf(name_en: path.start.name_en, type: path.start.type)
                    if(minDist[next].dist > minDist[cur].dist + path.dist) { // update
                        minDist[next].dist = minDist[cur].dist + path.dist
                        var newPoints = minDist[cur].points
                        for i in 0..<path.path.count {
                            newPoints.append(path.path[path.path.count - 1 - i])
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
    private func indexOf(name_en: String, type: Int) -> Int {
        for i in 0..<locations.count {
            if(locations[i].name_en == name_en && locations[i].type == type) {
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

// MARK: - extension
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}


