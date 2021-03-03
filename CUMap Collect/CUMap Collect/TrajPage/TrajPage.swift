import SwiftUI

struct TrajPage: View {
    // Updating and recording location
    @ObservedObject var locationModel: LocationModel
    @State var isRecording = false // if locations are being recorded
    @State var buttonScale: CGFloat = 0.8 // scale of rectangle of record button
    
    @State var showAlert = false
    
    // for process alert
    @State var showProcessAlert = false
    @State var processText = ""
    
    var body: some View {
        ZStack {
            TrajMapView(isRecording: $isRecording, locationModel: locationModel)
            
            VStack {
                Spacer()
                // two buttons
                HStack (spacing: SC_WIDTH * 0.1) {
                    
                    // record button
                    if isRecording { // to stop recording
                        Button(action: {
                            showAlert = true
                            isRecording.toggle()
                        }) {
                            ZStack {
                                Circle()
                                    .stroke(Color.gray, style: StrokeStyle(lineWidth: SC_WIDTH * 0.008))
                                    .frame(width: SC_WIDTH * 0.1, height: SC_WIDTH * 0.1)
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: SC_WIDTH * 0.085, height: SC_WIDTH * 0.085)
                                    .scaleEffect(buttonScale)
                                    .animation(Animation.linear(duration: 1.3).repeatForever(autoreverses: true))
                                }
                                .contentShape(Circle())
                        }
                        .onAppear { buttonScale = buttonScale == 0.8 ? 0.5 : 0.7 }
                    } else { // to start recording
                        Button(action: {
                            cleanRecord()
                            isRecording.toggle()
                        }) {
                            ZStack {
                                Circle()
                                    .stroke(Color.gray, style: StrokeStyle(lineWidth: SC_WIDTH * 0.008))
                                    .frame(width: SC_WIDTH * 0.1, height: SC_WIDTH * 0.1)
                                Circle()
                                    .fill(Color.red)
                                    .frame(width: SC_WIDTH * 0.085, height: SC_WIDTH * 0.085)
                                }
                        }
                    }
                    
                    // process button
                    Button(action: {
                        process()
                    }) {
                        Text("Process")
                            .foregroundColor(.black)
                            .font(.system(size: 20, weight: .bold, design: .rounded))
                            .padding(10)
                            .background(Color.white)
                            .cornerRadius(10)
                            .shadow(radius: 3)
                    }
                }
                // end of two button
            }
            .padding()
            showProcessAlert ? ProcessAlert(showing: $showProcessAlert, text: $processText) : nil
            
        }
        .ignoresSafeArea(.all, edges: .top)
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Upload or discard recorded data?"), primaryButton: .default(Text("Upload"), action: { uploadTrajs() }), secondaryButton: .destructive(Text("Discard"), action: { cleanRecord() }))
        }
    }
    
    private func uploadTrajs() {
        var trajs: [[[String: Any]]] = []
        for traj in locationModel.trajs {
            var points: [[String: Any]] = []
            for point in traj {
                if point.altitude != -1 {
                    points.append(["latitude": point.latitude, "longitude": point.longitude, "altitude": point.altitude])
                }
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
    
    struct Trajectory: Codable {
        var _id: String
        var points: [Coor3D]
    }
    
    
    private func cleanRecord() {
        locationModel.trajs = []
        locationModel.trajs.append([])
        locationModel.trajsIndex = 0
        locationModel.trajs[0].append(locationModel.current)
    }
    
    private func process() {
        showProcessAlert = true
        processText = ""
        
        let url = URL(string: server + "/process")!
        var request = URLRequest(url: url)
        request.httpMethod = "PUT"
        URLSession.shared.dataTask(with: request) { data, response, error in
            if error != nil {
                processText = "Error!"
                return
            }
            guard let data = data else { processText = "Error!"; return }
            do {
                let res = try JSONDecoder().decode(ProcessResult.self, from: data)
                if res.ok == 1 {
                    processText = "\(res.n) routes generated!"
                } else {
                    processText = "Error!"
                }
            } catch let error {
                processText = "Error!"
                print(error)
            }
        }.resume()
    }
}


struct ProcessAlert: View {
    @Binding var showing: Bool
    @Binding var text: String
    
    @State var angle: Double = 0
    
    var body: some View {
        ZStack {
            // background
            Color.gray.opacity(0.25).frame(maxWidth: .infinity, maxHeight: .infinity).ignoresSafeArea(.all).disabled(true)
            
            // content
            VStack(spacing: 0) {
                if text.isEmpty {
                    Image(systemName: "arrow.triangle.2.circlepath").imageScale(.large)
                        .rotationEffect(Angle(degrees: angle))
                        .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
                        .onAppear {
                            angle += 180
                        }.padding(.vertical, 20)
                } else {
                    Text(text).font(.headline).padding(.vertical, 20)
                }
                
                Divider()
                
                Button(action: {
                    showing.toggle()
                }) {
                    Text("OK")
                        .foregroundColor(text.isEmpty ? .gray : .blue)
                        .frame(width: UIScreen.main.bounds.width * 0.65, alignment: .center)
                        .padding(10)
                        .contentShape(Rectangle())
                }
                .buttonStyle(ShrinkDarkerButtonStyle(bgColor: Color.gray.opacity(0.3)))
                .disabled(text.isEmpty)
            }
            .frame(width: UIScreen.main.bounds.width * 0.65, alignment: .center)
            .background(Color.white)
            .cornerRadius(10)
            .clipped()
            .shadow(radius: 6)
        }
    }
}
