/* MARK: MapPage contains MapView + other functions */

import Foundation
import SwiftUI
import CoreLocation

struct MapPage: View {
    @Binding var locations: [Location]
    @Binding var trajectories: [[Coor3D]]
    @Binding var lineSegments: [LineSeg]
    @Binding var representatives: [[Coor3D]]
    @Binding var mapSys: [PathBtwn]
    @ObservedObject var locationGetter: LocationGetterModel

    /* sheet */
    @State var showCurrentLocation: Bool = true
    @State var showLocations: Bool = false // locations
    @State var showTrajs: Bool = true // trajectories
    @State var showLineSegs: Bool = false // lineSegments
    @State var showRepresents: Bool = false // representatives
    @State var showMap: Bool = false

    @State var showSheet: Bool = false
    
    /* gesture */
    @State var lastOffset = Offset(x: 0, y: 0)
    @State var offset = Offset(x: 0, y: 0)
    @State var lastScale = minZoomOut
    @State var scale = minZoomOut
    
    @State var uploadTasks: [Bool] = []
    @State var showAlert = false
    
    var body: some View {
        VStack {
            ZStack {
                MapView(locations: $locations, trajectories: $trajectories, lineSegments: $lineSegments, representatives: $representatives, mapSys: $mapSys, locationGetter: locationGetter, showCurrentLocation: $showCurrentLocation, showLocations: $showLocations, showTrajs: $showTrajs, showLineSegs: $showLineSegs, showRepresents: $showRepresents, showMap: $showMap, offset: $offset, scale: $scale)
            }
            HStack {
                Button(action: {
                    uploadTasks = [Bool](repeating: false, count: locationGetter.trajs.count)
                    for i in 0..<locationGetter.trajs.count {
                        uploadTraj(index: i)
                    }
                    
                } ) {Text("Upload")}
                Text(" / ")
                Button(action: {
                    cleanPaths()
                } ) {Text("Clear")}
            }
        }
            .padding()
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button(action: { showSheet = true }) { Text("Setting") } )
            .sheet(isPresented: $showSheet) {
                NavigationView {
                    FuncSheet(showCurrentLocation: $showCurrentLocation, showLocations: $showLocations, showTrajs: $showTrajs, showLineSegs: $showLineSegs, showRepresents: $showRepresents, showMap: $showMap, locations: $locations, trajectories: $trajectories, lineSegments: $lineSegments, representatives: $representatives, mapSys: $mapSys, locationGetter: locationGetter)
                        .navigationTitle("Setting")
                        .navigationBarTitleDisplayMode(.inline)
                        .navigationBarItems(trailing: Button(action: {showSheet = false}) { Text("Cancel")})
                }
            }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text("Can not connect to server."),
                    dismissButton: Alert.Button.default(Text("Try again")) {
                        for i in 0..<locationGetter.trajs.count {
                            if(!uploadTasks[i]) {
                                uploadTraj(index: i)
                            }
                        }
                    }
                )
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
    /* remove all data in locationGetter.paths */
    private func cleanPaths() {
        locationGetter.trajs = []
        locationGetter.trajs.append([])
        locationGetter.trajsIndex = 0
        locationGetter.trajs[0].append(locationGetter.current)
    }
    
    // MARK: - Upload a trajectory to Server
    private func uploadTraj(index: Int) {

        let traj = locationGetter.trajs[index]
        
        var items: [[String: Any]] = []
        for point in traj {
            items.append(["latitude": point.latitude, "longitude": point.longitude, "altitude": point.altitude])
        }
        let json = ["points": items]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: server + "/trajectory")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if(error != nil) {
                print("error")
            } else {
                guard let data = data else { return }
                do {
                    let res = try JSONDecoder().decode(TrajResponse.self, from: data)
                    if(res.success) {
                        trajectories.append(traj)
                        uploadTasks[index] = true
                    } else {
                        print("error")
                    }
                } catch let error {
                    print(error)
                }
            }
        }.resume()
    }
}
