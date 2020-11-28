/* MARK: MapPage contains MapView + other functions */

import Foundation
import SwiftUI
import CoreLocation

struct MapPage: View {
    @State var rawPaths: FetchedResults<RawPath>
    @Binding var locations: [Location]
    @ObservedObject var locationGetter: LocationGetterModel
    
    /* sheet */
    @State var showCurrentLocation: Bool = true
    @State var showRawPaths: Bool = false
    @State var showLocations: Bool = false
    @State var showClusters: Bool = true
    @State var showRepresentPaths: Bool = false
    @State var showSheet: Bool = false
    
    /* gesture */
    @State var lastOffset = Offset(x: 0, y: 0)
    @State var offset = Offset(x: 0, y: 0)
    @State var lastScale = CGFloat(1.0)
    @State var scale = CGFloat(1.0)
    @GestureState var magnifyBy = CGFloat(1.0)
    
    @Environment(\.managedObjectContext) private var viewContext
    @State var pathUnits: [PathUnit] = []
    @State var representPaths: [[CLLocation]] = []
    
    var body: some View {
        VStack {
            MapView(locationGetter: locationGetter, rawPaths: rawPaths, locations: $locations, showCurrentLocation: $showCurrentLocation, showRawPaths: $showRawPaths, showLocations: $showLocations, showClusters: $showClusters, showRepresentPaths: $showRepresentPaths, offset: $offset, scale: $scale, pathUnits: $pathUnits, representPaths: $representPaths)
            HStack {
                Button(action: {
                    for rawPath in locationGetter.paths {
                        if(rawPath.count >= 5) {
                            addRawPath(locations: rawPath)
                        }
                    }
                    cleanPaths()
                }) { Text("Upload") }
                Text(" / ")
                Button(action: {
                    cleanPaths()
                }) { Text("Discard") }
                Text(" / ")
                Button(action: {
                    /* clear */
                    pathUnits = []
                    representPaths = []
                    
                    /* partition */
                    for rawPath in rawPaths {
                        let cp = partition(path: rawPath.locations)
                        for index in 0...cp.count-2 {
                            let newPathUnit = PathUnit(context: viewContext)
                            newPathUnit.start_point = cp[index]
                            newPathUnit.end_point = cp[index+1]
                            pathUnits.append(newPathUnit)
                        }
                    }
                    
                    /* cluster */
                    let clusters = cluster(pathUnits: pathUnits)
                    var clusterNum = 0
                    for i in 0..<pathUnits.count {
                        pathUnits[i].clusterId = clusters[i]
                        clusterNum = max(clusterNum, clusters[i])
                    }
                    var C = [[PathUnit]](repeating: [], count: clusterNum)
                    for i in 0..<pathUnits.count {
                        if(clusters[i] != -1 && clusters[i] != 0) {
                            C[clusters[i] - 1].append(pathUnits[i])
                        }
                    }
                    /* representative trajectory */
                    for c in C {
                        let represent = generateRepresent(pathUnits: c)
                        if(represent.count >= 2) {
                            representPaths.append(represent)
                        }
                    }
                }) { Text("Process") }
            }
        }
            .navigationTitle("Map")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(trailing: Button(action: { showSheet = true }) { Text("Setting") } )
            .sheet(isPresented: $showSheet) {
                FuncSheet(showCurrentLocation: $showCurrentLocation, showRawPaths: $showRawPaths, showLocations: $showLocations, showClusters: $showClusters, showRepresentPaths: $showRepresentPaths, locations: $locations, locationGetter: locationGetter)
            }
            .contentShape(Rectangle())
            .gesture(
                SimultaneousGesture(
                    MagnificationGesture()
                        .updating($magnifyBy) { currentState, gestureState, transaction in
                            gestureState = currentState
                            var tmpScale = lastScale * magnifyBy
                            if(tmpScale < minZoomOut) {
                                tmpScale = minZoomOut
                            } else if(tmpScale > maxZoomIn) {
                                tmpScale = maxZoomIn
                            }
                            scale = tmpScale
                            offset = lastOffset * tmpScale / lastScale
                        }
                        .onEnded{ _ in
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
    
    // MARK: - Core Data function
    private func addPathUnit(start: CLLocation, end: CLLocation) {
        let newPathUnit = PathUnit(context: viewContext)
        newPathUnit.start_point = start
        newPathUnit.end_point = end
        do { try viewContext.save() }
        catch { fatalError("Error in addPathUnit.") }
    }
    private func deletePathUnit(offsets: IndexSet) {
        if(pathUnits.count == 0) { return }
        offsets.map { pathUnits[$0] }.forEach(viewContext.delete)
        do { try viewContext.save() }
        catch { fatalError("Error in deletePathUnit.") }
    }
    private func addRawPath(locations: [CLLocation]) {
        let newRawPath = RawPath(context: viewContext)
        newRawPath.locations = locations
        do { try viewContext.save() }
        catch { fatalError("Error in addRawPath.") }
    }
}

struct FuncSheet: View {
    @Binding var showCurrentLocation: Bool
    @Binding var showRawPaths: Bool
    @Binding var showLocations: Bool
    @Binding var showClusters: Bool
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
                Toggle(isOn: $showClusters) { Text("Show Clusters") }
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
        
        let url = NSURL(string: server + "/location")
        let request = NSMutableURLRequest(url: url! as URL)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        request.httpBody = dataStr.data(using: String.Encoding.utf8)
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        
        session.dataTask(with: request as URLRequest) { data, response, error in
            if(error != nil) {
                print("error")
            } else {
                guard let data = data else { return }
                do {
                    let res = try JSONDecoder().decode(Response.self, from: data)
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
