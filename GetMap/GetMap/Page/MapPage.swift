// MapPage contains MapView + other functions

import Foundation
import SwiftUI


struct MapPage: View {
    @Binding var locations: [Location]
    @Binding var trajectories: [Trajectory]

    @Binding var mapSys: [Route]

    @State var lineSegments: [LineSeg] = []
    @State var representatives: [[Coor3D]] = []
    
    // sheet
    @State var showTrajs: Bool = true // trajectories
    @State var showLineSegs: Bool = false // lineSegments
    @State var showRepresents: Bool = false // representatives
    @State var showMap: Bool = true

    @State var showSheet: Bool = false
    
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
            showMap ? Image("cuhk-campus-map")
                .resizable()
                .frame(width: 3200 * scale, height: 3200 * 25 / 20 * scale, alignment: .center)
                .position(x: centerX + offset.x, y: centerY + offset.y) : nil
            
            // raw trajectories
            showTrajs ? TrajsView(trajectories: $trajectories, color: Color.gray, offset: $offset, scale: $scale) : nil
            
            // line segments
            showLineSegs ? LineSegsView(lineSegments: $lineSegments, offset: $offset, scale: $scale) : nil
            
            // representative path
            showRepresents ? RepresentsView(trajs: $representatives, offset: $offset, scale: $scale) : nil
        }
        // navigation bar
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(action: { showSheet = true }) { Image(systemName: "gearshape").imageScale(.large) } )
        // function sheet
        .sheet(isPresented: $showSheet) {
            NavigationView {
                FuncSheet(showTrajs: $showTrajs, showLineSegs: $showLineSegs, showRepresents: $showRepresents, showMap: $showMap, locations: $locations, trajectories: $trajectories, lineSegments: $lineSegments, representatives: $representatives, mapSys: $mapSys)
                .navigationTitle("Setting")
            }
        }
        // gesture
        .contentShape(Rectangle())
        .gesture(gesture)
    }
}


var clusterNum: Int = 0

struct FuncSheet: View {
    @Binding var showTrajs: Bool
    @Binding var showLineSegs: Bool
    @Binding var showRepresents: Bool
    @Binding var showMap: Bool
    
    @Binding var locations: [Location]
    @Binding var trajectories: [Trajectory]
    @Binding var lineSegments: [LineSeg]
    @Binding var representatives: [[Coor3D]]
    @Binding var mapSys: [Route]
    
    @State var uploadTasks: [Bool] = []
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack {
                Toggle(isOn: $showTrajs) { Text("Show Raw Trajectories") }
                Toggle(isOn: $showLineSegs) { Text("Show Line Segments")}
                Toggle(isOn: $showRepresents) { Text("Show Representative path") }
                Toggle(isOn: $showMap) { Text("Show Background map")}
            }.padding()
            
            Divider()
            
            VStack {
                Button(action: {
                    // Step 1: partition
                    lineSegments = []
                    for traj in trajectories {
                        if(traj.points.count < 2) {
                            continue
                        }
                        let cp = partition(traj: traj.points)
                        for index in 0...cp.count-2 {
                            let newLineSeg = LineSeg(start: cp[index], end: cp[index+1], clusterId: 0)
                            lineSegments.append(newLineSeg)
                        }
                    }
                }) { Text("Partition").frame(width: UIScreen.main.bounds.width * 0.7) }
                .buttonStyle(MyButtonStyle(bgColor: CUPurple, disabled: false))
                
                Button(action: {
                    // Step 2: cluster
                    let clusterIds = cluster(lineSegs: lineSegments)
                    clusterNum = 0
                    for i in 0..<lineSegments.count {
                        lineSegments[i].clusterId = clusterIds[i]
                        clusterNum = max(clusterNum, clusterIds[i])
                    }
                }) { Text("Cluster").frame(width: UIScreen.main.bounds.width * 0.7) }
                .buttonStyle(MyButtonStyle(bgColor: CUPurple, disabled: false))
                
                Button(action: {
                    // Step 3: generate representative trajectory
                    representatives = []
                    var clusters = [[LineSeg]](repeating: [], count: clusterNum)
                    for lineSeg in lineSegments {
                        if(lineSeg.clusterId != -1 && lineSeg.clusterId != 0) {
                            clusters[lineSeg.clusterId - 1].append(lineSeg)
                        }
                    }
                    for cluster in clusters {
                        let repTraj = generateRepresent(lineSegs: cluster)
                        if(repTraj.count >= 2) {
                            representatives.append(repTraj)
                        }
                    }
                    representatives = smooth(trajs: representatives)
                }) { Text("Generate representative path").frame(width: UIScreen.main.bounds.width * 0.7) }
                .buttonStyle(MyButtonStyle(bgColor: CUPurple, disabled: false))
                
                /*
                Button(action: {
                    // Step 4: generate map system
                    let paths = GenerateMapSys(trajs: representatives, locations: locations)
                    for path in paths {
                        mapSys.append(path)
                    }
                }) { Text("Generate map system") }
                
                Button(action: {
                    // Step 5: upload map system
                    uploadTasks = [Bool](repeating: false, count: mapSys.count)
                    for i in 0..<mapSys.count {
                        uploadRoute(route: mapSys[i], index: i)
                    }
                        
                }) { Text("Upload map system") } */
            }.padding()
        }
    }
    private func uploadRoute(route: Route, index: Int) {
        var points: [[String: Any]] = []
        for point in route.points {
            points.append(["latitude": point.latitude, "longitude": point.longitude, "altitude": point.altitude])
        }
        let json: [String: Any] = [
            "startId": route.startLoc._id,
            "endId": route.endLoc._id,
            "points": points,
            "dist": route.dist,
            "type": route.type
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: server + "/route")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            do {
                let _ = try JSONDecoder().decode([Route].self, from: data)
                uploadTasks[index] = true
            } catch let error {
                print(error)
            }
        }.resume()
    }
}
