// For collecting data

import Foundation
import SwiftUI

struct CollectPage: View {
    @ObservedObject var locationGetter = LocationGetterModel()
    
    // if user point is at the center
    @State var mode: NavigationMode = .normal
    
    // gesture
    @State var lastOffset = Offset(x: 0, y: 0)
    @State var offset = Offset(x: 0, y: 0)
    @State var lastScale = minZoomOut
    @State var scale = minZoomOut
    
    // add location window
    @State var showAddLocation = false
    // if locations are being recorded
    @State var isRecording = true
    
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
                    mode = .normal
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
            Image("cuhk-campus-map")
                .resizable()
                .frame(width: 3200 * scale, height: 3200 * 25 / 20 * scale, alignment: .center)
                .position(x: centerX + offset.x, y: centerY + offset.y)
                .gesture(gesture)

            // recording trajectory
            if isRecording {
                UserPathsView(locationGetter: locationGetter, offset: $offset, scale: $scale)
            }
            UserPoint(locationGetter: locationGetter, offset: $offset, scale: $scale)
            // tool bar
            VStack {
                Spacer()
                HStack(spacing: 30) {
                    ModeButton(locationGetter: locationGetter, mode: $mode, lastOffset: $lastOffset, offset: $offset, lastScale: $lastScale, scale: $scale)
                    RecordButton(locationGetter: locationGetter, isRecording: $isRecording)
                    DeleteButton(locationGetter: locationGetter)
                }
            }
            if showAddLocation {
                NewLocationWindow(locationGetter: locationGetter, showing: $showAddLocation)
            }
        }
        // navigation bar
        .navigationTitle("Collect")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing:
            Button(action: { showAddLocation = true }) {
                Image(systemName: "plus.circle").imageScale(.large).contentShape(Rectangle())
            }
        )
    }
}

// MARK: - Tool Bar
struct ModeButton: View {
    @ObservedObject var locationGetter: LocationGetterModel
    @Binding var mode: NavigationMode
    
    @Binding var lastOffset: Offset
    @Binding var offset: Offset
    @Binding var lastScale: CGFloat
    @Binding var scale: CGFloat
    
    var body: some View {
        Button(action: {
            if(mode == .normal) {
                mode = .undirected
                if(offset == lastOffset && scale == lastScale) {
                    offset.x = CGFloat((centerLg - locationGetter.current.longitude)*lgScale*2) * scale
                    offset.y = CGFloat((locationGetter.current.latitude - centerLa)*laScale*2) * scale
                    lastOffset = offset
                }
            } else if(mode == .directed) {
                mode = .normal
                if(offset == lastOffset && scale == lastScale) {
                    offset.x = CGFloat((centerLg - locationGetter.current.longitude)*lgScale*2) * scale
                    offset.y = CGFloat((locationGetter.current.latitude - centerLa)*laScale*2) * scale
                    lastOffset = offset
                }
            } else {
                mode = .directed
                // TODO: directed mode 
            }
        }) {
            if mode == .normal {
                Image(systemName: "location")
                    .resizable()
                    .frame(width: SCWidth * 0.085, height: SCWidth * 0.09, alignment: .center)
                    .foregroundColor(CUPurple)
            } else if mode == .undirected {
                Image(systemName: "location.fill")
                    .resizable()
                    .frame(width: SCWidth * 0.085, height: SCWidth * 0.09, alignment: .center)
                    .foregroundColor(CUPurple)
            } else if mode == .directed {
                Image(systemName: "location.north.line.fill")
                    .resizable()
                    .frame(width: SCWidth * 0.055, height: SCWidth * 0.09, alignment: .center)
                    .foregroundColor(CUPurple)
            }
        }
        .frame(width: SCWidth * 0.1, height: SCWidth * 0.1, alignment: .center)
    }
}

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

// MARK: - New Location Window
struct NewLocationWindow: View {
    @ObservedObject var locationGetter: LocationGetterModel
    @Binding var showing: Bool
    
    @State var locationName: String = ""
    @State var locationType: String = ""
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Rectangle()
                    .frame(minWidth: geometry.size.width, maxWidth: .infinity, minHeight: geometry.size.height, maxHeight: .infinity, alignment: .center)
                    .foregroundColor(Color.gray.opacity(0.2))
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showing = false
                    }
                VStack(spacing: 20) {
                    Text("New Location").font(.title2)
                    VStack {
                        TextField("Name", text: $locationName)
                            .padding(10)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.8))
                        TextField("Type", text: $locationType)
                            .padding(10)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.8))
                    }
                    HStack {
                        Button(action: {
                            addLocation()
                            showing = false
                        }) { Text("Confirm") }
                            .disabled(locationName == "" || locationType == "")
                            .buttonStyle(MyButtonStyle(bgColor: CUPurple, disabled: locationName == "" || locationType == ""))
                        
                        Button(action: { showing = false }) { Text("Cancel") }
                            .buttonStyle(MyButtonStyle(bgColor: CUPurple, disabled: false))
                    }
                }
                .padding(20)
                .frame(width: geometry.size.width * 0.7, alignment: .center)
                .background(Color.white)
                .cornerRadius(5)
            }
        }
    }
    
    private func addLocation() {
        let latitude = locationGetter.current.latitude
        let longitude = locationGetter.current.longitude
        let altitude = locationGetter.current.altitude
        let type = Int(locationType)!
        let dataStr = "name_en=" + String(locationName) + "&latitude=" + String(latitude)  + "&longitude=" + String(longitude) + "&altitude=" + String(altitude) + "&type=" + String(type)
        
        let url = URL(string: server + "/location")!
        var request = URLRequest(url: url)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = dataStr.data(using: String.Encoding.utf8)

        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if(error != nil) {
                print("error")
            } else {
                guard let data = data else { return }
                do {
                    let _ = try JSONDecoder().decode(Location.self, from: data)
                    locationName = ""
                    locationType = ""
                } catch let error {
                    print(error)
                }
            }
        }.resume()
    }
}
