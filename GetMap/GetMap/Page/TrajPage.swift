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
        .navigationTitle("Collect")
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

    @State var taskStatus = [TaskStatus](repeating: .pending, count: 8)
    // @State var taskStatus = [TaskStatus](repeating: .fail, count: 8)
    
    var body: some View {
        VStack {
            // start process button
            Button(action: {
                taskStatus[1] = .processing
                taskStatus[0] = .processing
            }) { Text("Start") }.buttonStyle(MyButtonStyle(bgColor: CUPurple, disabled: false))
            Divider()
            
            // steps
            List {
                HStack {
                    Text("Load locations")
                    Spacer()
                    TaskStatusImage(status: $taskStatus[0])
                }
                HStack {
                    Text("Load trajectories")
                    Spacer()
                    TaskStatusImage(status: $taskStatus[1])
                }
                HStack {
                    Text("Partition trajectories into line segments")
                    Spacer()
                    TaskStatusImage(status: $taskStatus[2])
                }
                HStack {
                    Text("Cluster line segments")
                    Spacer()
                    TaskStatusImage(status: $taskStatus[3])
                }
                HStack {
                    Text("Generate representative paths")
                    Spacer()
                    TaskStatusImage(status: $taskStatus[4])
                }
                HStack {
                    Text("Generate routes between two locations")
                    Spacer()
                    TaskStatusImage(status: $taskStatus[5])
                }
                HStack {
                    Text("Delete routes in database")
                    Spacer()
                    TaskStatusImage(status: $taskStatus[6])
                }
                HStack {
                    Text("Upload routes")
                    Spacer()
                    TaskStatusImage(status: $taskStatus[7])
                }
            }
        }
        /*
         Task flow:
         1 -> 2 -> 3 -> 4 ->
                        0 -> 5 ->
                             6 -> 7
         */
        .onChange(of: taskStatus[0], perform: { value in
            if value == .processing {
                startTask(index: 0)
            } else if value == .success && taskStatus[4] == .success {
                taskStatus[5] = .processing
            }
        })
        .onChange(of: taskStatus[1], perform: { value in
            if value == .processing {
                startTask(index: 1)
            } else if value == .success {
                taskStatus[2] = .processing
            }
        })
        .onChange(of: taskStatus[2], perform: { value in
            if value == .processing {
                startTask(index: 2)
            } else if value == .success {
                taskStatus[3] = .processing
            }
        })
        .onChange(of: taskStatus[3], perform: { value in
            if value == .processing {
                startTask(index: 3)
            } else if value == .success {
                taskStatus[4] = .processing
            }
        })
        .onChange(of: taskStatus[4], perform: { value in
            if value == .processing {
                startTask(index: 4)
            } else if value == .success && taskStatus[0] == .success {
                taskStatus[5] = .processing
            }
        })
        .onChange(of: taskStatus[5], perform: { value in
            if value == .processing {
                startTask(index: 5)
            } else if value == .success && taskStatus[6] == .success {
                taskStatus[7] = .processing
            }
        })
        .onChange(of: taskStatus[6], perform: { value in
            if value == .processing {
                startTask(index: 6)
            } else if value == .success && taskStatus[5] == .success {
                taskStatus[7] = .processing
            }
        })
        .onChange(of: taskStatus[7], perform: { value in
            if value == .processing {
                startTask(index: 7)
            }
        })
    }

    private func startTask(index: Int) {
        switch index {
            case 0: loadLocations()
            case 1: loadTrajs()
            case 2: partition()
            case 3: cluster()
            case 4: generRepresents()
            case 5: generRoutes()
            case 6: deleteRoutes()
            case 7: uploadRoutes()
            default: return
                
        }
    }
    private func loadLocations() { // Task 0
        let url = URL(string: server + "/locations")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if(error != nil) {
                taskStatus[0] = .fail
            }
            guard let data = data else { return }
            do {
                locations = try JSONDecoder().decode([Location].self, from: data)
                taskStatus[0] = .success
            } catch let error {
                taskStatus[0] = .fail
                print(error)
            }
        }.resume()
    }
    private func loadTrajs() { // Task 1
        let url = URL(string: server + "/trajectories")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if(error != nil) {
                taskStatus[1] = .fail
            }
            guard let data = data else { return }
            do {
                trajectories = try JSONDecoder().decode([Trajectory].self, from: data)
                taskStatus[1] = .success
            } catch let error {
                taskStatus[1] = .fail
                print(error)
            }
        }.resume()
    }
    private func partition() { // Task 2: Partition trajectories into line segments
        lineSegments = []
        for traj in trajectories {
            if(traj.points.count < 2) {
                continue
            }
            let cp = GetMap.partition(traj: traj.points)
            for index in 0...cp.count-2 {
                let newLineSeg = LineSeg(start: cp[index], end: cp[index+1], clusterId: 0)
                lineSegments.append(newLineSeg)
            }
        }
        taskStatus[2] = .success
    }
    private func cluster() { // Task 3: Cluster line segments
        let clusterIds = GetMap.cluster(lineSegs: lineSegments)
        clusterNum = 0
        for i in 0..<lineSegments.count {
            lineSegments[i].clusterId = clusterIds[i]
            clusterNum = max(clusterNum, clusterIds[i])
        }
        taskStatus[3] = .success
    }
    private func generRepresents() { // Task 4: Generate representative paths
        taskStatus[4] = .success
    }
    private func generRoutes() { // Task 5: Generate routes between two locations
        taskStatus[5] = .success
    }
    private func deleteRoutes() { // Task 6: delete routes
        taskStatus[6] = .success
    }
    private func uploadRoutes() { // Task 7: upload routes
        taskStatus[7] = .success
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
                .foregroundColor(.gray)
        } else if status == .success {
            Image(systemName: "checkmark.circle.fill")
                .imageScale(.large)
                .foregroundColor(.green)
        } else if status == .fail {
            Image(systemName: "exclamationmark.circle.fill")
                .imageScale(.large)
                .foregroundColor(.red)
                .onTapGesture {
                    status = .processing
                }
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
