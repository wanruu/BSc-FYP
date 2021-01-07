// For collecting data

import Foundation
import SwiftUI

struct TrajPage: View {
    
    // Updating and recording location
    @StateObject var locationGetter = LocationGetterModel()
    @State var isRecording = true // if locations are being recorded
    
    // control add location window
    @State var showProcess = false
    
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
        .navigationTitle("Trajectory")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
            Button(action: { showProcess = true }) {
                Image(systemName: "gearshape").imageScale(.large)
            }
        )
        // function sheet
        .sheet(isPresented: $showProcess) {
            NavigationView {
                ProcessSheet()
                    .navigationTitle("Process")
            }
        }
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


// MARK: - Process Sheet
struct ProcessSheet: View {
    @State var locations: [Location] = []
    @State var trajectories: [Trajectory] = []
    @State var lineSegments: [LineSeg] = []
    @State var representatives: [[Coor3D]] = []
    @State var routes: [Route] = []
    
    @State var taskStatus = [TaskStatus](repeating: .pending, count: 7)
    
    var body: some View {
        VStack {
            // start process button
            Button(action: {
                taskStatus[0] = .processing
                taskStatus[1] = .processing
            }) {
                Text("Start")
            }.buttonStyle(MyButtonStyle(bgColor: CUPurple, disabled: false))
            Divider()
            
            // steps
            List {
                // Task 0
                HStack {
                    Text("Load locations")
                    Spacer()
                    TaskStatusImage(status: $taskStatus[0])
                }
                // Task 1
                HStack {
                    Text("Load trajectories")
                    Spacer()
                    TaskStatusImage(status: $taskStatus[1])
                }
                // Task 2
                HStack {
                    Text("Partition trajectories into line segments")
                    Spacer()
                    TaskStatusImage(status: $taskStatus[2])
                }
                // Task 3
                HStack {
                    Text("Cluster line segments")
                    Spacer()
                    TaskStatusImage(status: $taskStatus[3])
                }
                // Task 4
                HStack {
                    Text("Generate representative paths")
                    Spacer()
                    TaskStatusImage(status: $taskStatus[4])
                }
                // Task 5
                HStack {
                    Text("Generate routes between two locations")
                    Spacer()
                    TaskStatusImage(status: $taskStatus[5])
                }
                // Task 6
                HStack {
                    Text("Upload routes")
                    Spacer()
                    TaskStatusImage(status: $taskStatus[6])
                }
            }
            // end of list
        }
    }
    
    
}

enum TaskStatus {
    case pending
    case success
    case fail
    case processing
}

struct TaskStatusImage: View {
    @Binding var status: TaskStatus
    
    @State var angle: Double = 0
    
    var body: some View {
        if status == .pending {
            Image(systemName: "hourglass.bottomhalf.fill")
                .imageScale(.large)
        } else if status == .success {
            Image(systemName: "checkmark")
                .imageScale(.large)
        } else if status == .fail {
            Image(systemName: "exclamationmark")
                .imageScale(.large)
        } else if status == .processing {
            Image(systemName: "arrow.clockwise")
                .imageScale(.large)
                .rotationEffect(Angle(degrees: angle))
                .animation(Animation.linear(duration: 1.5).repeatForever(autoreverses: false))
                .onAppear {
                    angle += 360
                }
        }
    }
}
