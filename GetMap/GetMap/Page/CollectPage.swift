// MARK: For collecting data

import Foundation
import SwiftUI

struct CollectPage: View {
    @Binding var locations: [Location]
    @Binding var trajectories: [[Coor3D]]
    
    // gesture
    @State var lastOffset = Offset(x: 0, y: 0)
    @State var offset = Offset(x: 0, y: 0)
    @State var lastScale = minZoomOut
    @State var scale = minZoomOut
    @State var isGestureChanging = false
    
    // add location window
    @State var showAddLocation = false
    
    // collect traj data
    @ObservedObject var locationGetter = LocationGetterModel()
    
    // if user point is at the center
    @State var isCenter = false
    // if locations are being recorded
    @State var isRecording = true
    
    // uploading
    @State var showUploadAlert = false
    
    var body: some View {
        ZStack {
            Image("cuhk-campus-map")
                .resizable()
                .frame(width: 3200 * scale, height: 3200 * 25 / 20 * scale, alignment: .center)
                .position(x: centerX + offset.x, y: centerY + offset.y)
                // Gesture
                .contentShape(Rectangle())
                .gesture(
                    SimultaneousGesture(
                        MagnificationGesture()
                        .onChanged { value in
                            isGestureChanging = true
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
                            lastOffset = offset
                            isGestureChanging = false
                        },
                        DragGesture()
                        .onChanged{ value in
                            isGestureChanging = true
                            isCenter = false
                            offset.x = lastOffset.x + value.location.x - value.startLocation.x
                            offset.y = lastOffset.y + value.location.y - value.startLocation.y
                        }
                        .onEnded{ _ in
                            lastOffset = offset
                            isGestureChanging = false
                        }
                    )
                )
            // trajs data from server
            TrajsView(trajectories: $trajectories, color: Color.gray, offset: $offset, scale: $scale)
            // recording trajectory
            isRecording ? UserPathsView(locationGetter: locationGetter, offset: $offset, scale: $scale) : nil
            
            UserPoint(locationGetter: locationGetter, offset: $offset, scale: $scale)
            VStack {
                Spacer()
                HStack {
                    // change to current location
                    Button(action: {
                        if(!isGestureChanging) {
                            offset.x = CGFloat((centerLg - locationGetter.current.longitude)*lgScale*2) * scale
                            offset.y = CGFloat((locationGetter.current.latitude - centerLa)*laScale*2) * scale
                            lastOffset = offset
                        }
                        isCenter = !isCenter
                    }) {
                        isCenter ?
                            Image(systemName: "location.fill")
                            .resizable()
                            .frame(width: SCWidth * 0.08, height: SCWidth * 0.08, alignment: .center) :
                            Image(systemName: "location")
                            .resizable()
                            .frame(width: SCWidth * 0.08, height: SCWidth * 0.08, alignment: .center)
                    }.padding()
                    
                    // start/stop record trajectory
                    Button(action: {
                        isRecording ? uploadTrajs() : startRecord()
                        isRecording = !isRecording
                    }) {
                        isRecording ?
                            Image(systemName: "stop.circle")
                            .resizable()
                            .frame(width: SCWidth * 0.08, height: SCWidth * 0.08, alignment: .center) :
                            Image(systemName: "largecircle.fill.circle")
                            .resizable()
                            .frame(width: SCWidth * 0.08, height: SCWidth * 0.08, alignment: .center)
                    }.padding()
                }
            }
        }
        // navigation bar
        .navigationTitle("Collect")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(action: {showAddLocation = true}) {Image(systemName: "plus.circle").imageScale(.large)}.contentShape(Rectangle()))
        // alert
        .alert(isPresented: $showAddLocation) {
            Alert(title: Text("New Location"))
        }
        .alert(isPresented: $showUploadAlert) {
            Alert(
                title: Text("Error"),
                message: Text("Failed to upload."),
                dismissButton: Alert.Button.default(Text("Try again")) {
                    uploadTrajs()
                }
            )
        }
    }
    private func startRecord() {
        locationGetter.trajs = []
        locationGetter.trajs.append([])
        locationGetter.trajsIndex = 0
        locationGetter.trajs[0].append(locationGetter.current)
    }
    private func uploadTrajs() {
        var trajs: [[[String: Any]]] = []
        for traj in locationGetter.trajs {
            var points: [[String: Any]] = []
            for point in traj {
                points.append(["latitude": point.latitude, "longitude": point.longitude, "altitude": point.altitude])
            }
            trajs.append(points)
        }

        let json = ["trajectories": trajs]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: server + "/trajectories")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if(error != nil) {
                showUploadAlert = true
            } else {
                guard let data = data else { return }
                do {
                    let res = try JSONDecoder().decode(TrajResponse.self, from: data)
                    if(res.success) {
                        for traj in locationGetter.trajs {
                            trajectories.append(traj)
                        }
                    } else {
                        showUploadAlert = true
                    }
                } catch let error {
                    print(error)
                }
            }
        }.resume()
    }
}
