// For collecting data

import Foundation
import SwiftUI

struct TrajPage: View {
    
    // Updating and recording location
    @StateObject var locationGetter = LocationGetterModel()
    @State var isRecording = true // if locations are being recorded
    @State var buttonScale: CGFloat = 0.8 // scale of rectangle of record button
    @State var showAlert = false

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
            
            VStack {
                Spacer()
                HStack (spacing: SCWidth * 0.1) {
                    // record button
                    ZStack {
                        // outer gray circle
                        Circle()
                            .stroke(Color.gray, style: StrokeStyle(lineWidth: SCWidth * 0.008))
                            .frame(width: SCWidth * 0.1, height: SCWidth * 0.1)
                        
                        // inner red circle
                        if isRecording {
                            Button(action: {
                                showAlert = true
                                isRecording.toggle()
                            }) {
                                Circle().fill(Color.red).frame(width: SCWidth * 0.085, height: SCWidth * 0.085)
                            }
                            .buttonStyle(ZoomOutStyle())
                            .scaleEffect(isRecording ? buttonScale : 1)
                            .animation(Animation.linear(duration: 1.3).repeatForever(autoreverses: true))
                            .onAppear { buttonScale = buttonScale == 0.8 ? 0.5 : 0.7 }
                        } else {
                            Button(action: {
                                isRecording.toggle()
                            }) {
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: SCWidth * 0.085, height: SCWidth * 0.085)
                            }
                            .buttonStyle(ZoomOutStyle())
                        }
                    }
                    // process button
                    Button(action: {
                        process()
                    }) {
                        Text("Process")
                            .foregroundColor(.black)
                            .font(.system(size: 25, weight: .bold, design: .rounded))
                    }.buttonStyle(ZoomOutStyle())
                }
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Upload or discard recorded data?"), primaryButton: .default(Text("Upload"), action: { uploadTrajs() }), secondaryButton: .default(Text("Discard"), action: { cleanRecord() }))
        }
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
    
    private func cleanRecord() {
        locationGetter.trajs = []
        locationGetter.trajs.append([])
        locationGetter.trajsIndex = 0
        locationGetter.trajs[0].append(locationGetter.current)
    }
    
    private func process() {
        let url = URL(string: server + "/process")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            do {
                let res = try JSONDecoder().decode(ProcessResult.self, from: data)
                if res.ok == 1 {
                    print("success")
                }
            } catch let error {
                print(error)
            }
        }.resume()
    }
}
