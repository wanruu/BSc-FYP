/* MARK: MapPage contains MapView + other functions */

import Foundation
import SwiftUI

struct MapPage: View {
    @Binding var locations: [Location]
    @Binding var trajectories: [[Coor3D]]
    @Binding var representatives: [[Coor3D]]
    @ObservedObject var locationGetter: LocationGetterModel

    /* sheet */
    @State var showCurrentLocation: Bool = true
    @State var showRawPaths: Bool = true
    @State var showLocations: Bool = false
    @State var showRepresentPaths: Bool = false
    @State var showSheet: Bool = false
    
    /* gesture */
    @State var lastOffset = Offset(x: 0, y: 0)
    @State var offset = Offset(x: 0, y: 0)
    @State var lastScale = CGFloat(1.0)
    @State var scale = CGFloat(1.0)
    
    var body: some View {
        VStack {
            ZStack {
                MapView(locations: $locations, trajectories: $trajectories, representatives: $representatives, locationGetter: locationGetter, showCurrentLocation: $showCurrentLocation, showRawPaths: $showRawPaths, showLocations: $showLocations, showRepresentPaths: $showRepresentPaths, offset: $offset, scale: $scale)
                    .contentShape(Rectangle())
            }
            Button(action: {
                representatives = process(trajs: trajectories)
            } ) {Text("Process")}
        }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button(action: { showSheet = true }) { Text("Setting") } )
            .sheet(isPresented: $showSheet) {
                FuncSheet(showCurrentLocation: $showCurrentLocation, showRawPaths: $showRawPaths, showLocations: $showLocations, showRepresentPaths: $showRepresentPaths, locations: $locations, locationGetter: locationGetter)
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
        locationGetter.paths = []
        locationGetter.paths.append([])
        locationGetter.pathCount = 0
        locationGetter.paths[0].append(locationGetter.current)
    }
}

struct FuncSheet: View {
    @Binding var showCurrentLocation: Bool
    @Binding var showRawPaths: Bool
    @Binding var showLocations: Bool
    @Binding var showRepresentPaths: Bool
    
    @Binding var locations: [Location]
    @ObservedObject var locationGetter: LocationGetterModel
    
    @State var locationName: String = ""
    @State var locationType: String = ""
    var body: some View {
       VStack {
            VStack {
                Text("Setting").font(.headline)
                Divider()
                Toggle(isOn: $showCurrentLocation) { Text("Show Current Location") }
                Toggle(isOn: $showRawPaths) { Text("Show Raw Paths") }
                Toggle(isOn: $showLocations) { Text("Show Locations") }
                Toggle(isOn: $showRepresentPaths) { Text("Show Representatives") }
            }.padding()
            VStack {
                Text("New Location").font(.headline)
                Divider()
                TextField("Type of the building", text: $locationType)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField( "Name of the building", text: $locationName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    guard locationName != "" else { return }
                    guard Int(locationType) != nil else { return }
                    addLocation()
                }) { Text("Add") }
            }.padding()
            Spacer()
        }
    }
    private func addLocation() {
        /* data */
        let latitude = locationGetter.current.coordinate.latitude
        let longitude = locationGetter.current.coordinate.longitude
        let altitude = locationGetter.current.altitude
        let type = Int(locationType)!
        let dataStr = "name_en=" + String(locationName) + "&latitude=" + String(latitude)  + "&longitude=" + String(longitude) + "&altitude=" + String(altitude) + "&type=" + String(type)
        
        let url = URL(string: server + "/location")!
        var request = URLRequest(url: url)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        request.httpBody = dataStr.data(using: String.Encoding.utf8)

        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if(error != nil) {
                print("error")
            } else {
                guard let data = data else { return }
                do {
                    let res = try JSONDecoder().decode(LocResponse.self, from: data)
                    if(res.success) {
                        let newLocation = Location(name_en: locationName, latitude: latitude, longitude: longitude, altitude: altitude, type: type)
                        locations.append(newLocation)
                        locationName = ""
                        locationType = ""
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
