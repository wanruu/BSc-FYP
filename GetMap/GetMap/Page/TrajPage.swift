// For collecting data

import Foundation
import SwiftUI

struct TrajPage: View {
    
    // Updating and recording location
    @StateObject var locationGetter = LocationGetterModel()
    @State var isRecording = true // if locations are being recorded

    
    // gesture
    @State var lastOffset = Offset(x: 0, y: 0)
    @State var offset = Offset(x: 0, y: 0)
    @State var lastScale = minZoomOut
    @State var scale = minZoomOut
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
                    lastOffset = offset
                },
            DragGesture()
                .onChanged{ value in
                    offset.x = lastOffset.x + value.location.x - value.startLocation.x
                    offset.y = lastOffset.y + value.location.y - value.startLocation.y
                }
                .onEnded{ _ in
                    lastOffset = offset
                }
        )
    }
    
    var body: some View {
        ZStack {
            // Background map image
            Image("cuhk-campus-map")
                .resizable()
                .frame(width: 3200 * scale, height: 3200 * 25 / 20 * scale, alignment: .center)
                .position(x: centerX + offset.x, y: centerY + offset.y)
                .gesture(gesture)

            // recording trajectory
            if isRecording { // TODO: need judge isRecording?
                UserPathsView(locationGetter: locationGetter, offset: $offset, scale: $scale)
            }
            
            // current location
            UserPoint(locationGetter: locationGetter, offset: $offset, scale: $scale)
            
            // tool bar
            VStack {
                Spacer()
                HStack(spacing: 30) {
                    RecordButton(locationGetter: locationGetter, isRecording: $isRecording)
                    DeleteButton(locationGetter: locationGetter)
                }
            }
        }
        // navigation bar
        .navigationTitle("Collect")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
            Button(action: {
                // TODO: add process button action
            }) {
                Image(systemName: "gearshape").imageScale(.large)
            }
        )
    }
}

// MARK: - Tool Bar
struct RecordButton: View {
    @ObservedObject var locationGetter: LocationGetterModel
    @Binding var isRecording: Bool
    
    var body: some View {
        Button(action: {
            isRecording ? uploadTrajs() : startRecord()
            isRecording = !isRecording
        }) {
            isRecording ?
                Image(systemName: "stop.circle")
                    .resizable()
                    .frame(width: SCWidth * 0.08, height: SCWidth * 0.08, alignment: .center)
                    .foregroundColor(CUPurple) :
                Image(systemName: "largecircle.fill.circle")
                    .resizable()
                    .frame(width: SCWidth * 0.08, height: SCWidth * 0.08, alignment: .center)
                    .foregroundColor(CUPurple)
        }
        .frame(width: SCWidth * 0.1, height: SCWidth * 0.1, alignment: .center)
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
            if points.count > 1 {
                trajs.append(points)
            }
        }
        if trajs.count == 0 {
            return
        }

        let json = ["trajectories": trajs]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: server + "/trajectories")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            do {
                let _ = try JSONDecoder().decode([Trajectory].self, from: data)
            } catch let error {
                print(error)
            }
        }.resume()
    }
}

struct DeleteButton: View {
    @ObservedObject var locationGetter: LocationGetterModel
    var body: some View {
        Button(action: {
            locationGetter.trajs = []
            locationGetter.trajs.append([])
            locationGetter.trajsIndex = 0
            locationGetter.trajs[0].append(locationGetter.current)
        }) {
            Image(systemName: "trash")
                .resizable()
                .frame(width: SCWidth * 0.08, height: SCWidth * 0.08, alignment: .center)
                .foregroundColor(CUPurple)
        }.frame(width: SCWidth * 0.1, height: SCWidth * 0.1, alignment: .center)
    }
}
