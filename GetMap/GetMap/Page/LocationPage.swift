/* MARK: Location Page - a list of locations */

import Foundation
import SwiftUI

struct LocationPage: View {
    @Binding var locations: [Location]
    // gesture
    @State var offset: Offset = Offset(x: 0, y: 0)
    @State var lastOffset = Offset(x: 0, y: 0)
    @State var scale: CGFloat = minZoomOut
    @State var lastScale = minZoomOut
    // sheet & alert
    @State var showList = false

    // clicked location
    @State var id: String = ""
    @State var name_en: String = ""
    @State var latitude: String = ""
    @State var longitude: String = ""
    @State var altitude: String = ""
    @State var type: String = ""
    
    var body: some View {
        ZStack {
            // map
            Image("cuhk-campus-map")
            .resizable()
            .frame(width: 3200 * scale, height: 3200 * 25 / 20 * scale, alignment: .center)
            .position(x: centerX + offset.x, y: centerY + offset.y)
            // locations
            LocationsView(locations: $locations, id: $id, name_en: $name_en, latitude: $latitude, longitude: $longitude, altitude: $altitude, type: $type, offset: $offset, scale: $scale)
        }
        // gesture
        .contentShape(Rectangle())
        .highPriorityGesture(SimultaneousGesture(
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
        // navigation bar
        .navigationTitle("Location")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(action: {showList = true}) {Image(systemName: "list.bullet").imageScale(.large)} )
        // sheet: list
        .sheet(isPresented: $showList) {
            NavigationView {
                List {
                    ForEach(locations) { location in
                        Button(action: {
                            id = location.id
                            name_en = location.name_en
                            latitude = String(location.latitude)
                            longitude = String(location.longitude)
                            altitude = String(location.altitude)
                            type = String(location.type)
                            showList = false
                            // move selected location to center
                            scale = maxZoomIn
                            lastScale = maxZoomIn
                            offset.x = CGFloat((centerLg - location.longitude)*lgScale*2) * scale
                            offset.y = CGFloat((location.latitude - centerLa)*laScale*2) * scale
                            lastOffset = offset
                        }) {
                            HStack {
                                Image(systemName: location.type == 0 ? "building.2" : "bus")
                                VStack(alignment: .leading) {
                                    Text(location.name_en).font(.headline)
                                    Text("(\(location.latitude), \(location.longitude), \(location.altitude)").font(.subheadline)
                                }
                            }
                        }
                    }
                    .onDelete { offsets in
                        let index = offsets.first!
                        deleteLocation(location: locations[index], index: index)
                    }
                }
                .navigationTitle("Location List")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button(action: { showList = false }) { Text("Cancel") })
            }
        }
    }
    
    private func deleteLocation(location: Location, index: Int) {
        let dataStr = "id=" + location.id
        
        let url = URL(string: server + "/location")!
        var request = URLRequest(url: url)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"
        request.httpBody = dataStr.data(using: String.Encoding.utf8)
        
        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if(error != nil) {
                print("error")
            } else {
                guard let data = data else { return }
                do {
                    let res = try JSONDecoder().decode(DeleteResult.self, from: data)
                    if(res.deletedCount == 1) {
                        locations.remove(at: index)
                    }
                } catch let error {
                    print(error)
                }
            }
        }.resume()
    }
}

struct LocationsView: View {
    @Binding var locations: [Location]
    
    @Binding var id: String
    @Binding var name_en: String
    @Binding var latitude: String
    @Binding var longitude: String
    @Binding var altitude: String
    @Binding var type: String
    
    @Binding var offset: Offset
    @Binding var scale: CGFloat

    var body: some View {
        let filtered = locations.filter{$0.id == id}
        let showedLocation = filtered.count == 0 ? nil : filtered[0]
        
        return ZStack {
            ForEach(locations) { location in
                Button(action: {
                    if(location.id == id) {
                        id = ""
                    } else {
                        id = location.id
                        name_en = location.name_en
                        latitude = String(location.latitude)
                        longitude = String(location.longitude)
                        altitude = String(location.altitude)
                        type = String(location.type)
                    }
                }) {
                    location.id == id ?
                    Image("location-white")
                        .resizable()
                        .frame(width: SCWidth * 0.1, height: SCWidth * 0.1, alignment: .center) :
                    Image(location.type == 0 ? "location-purple" : "location-yellow")
                        .resizable()
                        .frame(width: SCWidth * 0.1, height: SCWidth * 0.1, alignment: .center)
                    
                }
                .position(
                    x: centerX + CGFloat((location.longitude - centerLg)*lgScale*2) * scale + offset.x,
                    y: centerY + CGFloat((centerLa - location.latitude)*laScale*2) * scale + offset.y - SCWidth * 0.05
                )
            }
            id == "" ? nil :
                VStack {
                    TextField("Name", text: $name_en).textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Latitude", text: $latitude).textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Longitude", text: $longitude).textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Altitude", text: $altitude).textFieldStyle(RoundedBorderTextFieldStyle())
                    TextField("Type", text: $type).textFieldStyle(RoundedBorderTextFieldStyle())
                    HStack {
                        Button(action: {
                            editLocation()
                        }) { Text("Submit") }
                        .disabled(Double(latitude) == nil || Double(longitude) == nil || Double(altitude) == nil || Int(type) == nil)
                        Button(action: {
                            id = ""
                        }) { Text("Cancel") }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(10)
                .frame(width: SCWidth * 0.5)
                .position(
                    x: centerX + CGFloat((showedLocation!.longitude - centerLg)*lgScale*2) * scale + offset.x,
                    y: centerY + CGFloat((centerLa - showedLocation!.latitude)*laScale*2) * scale + offset.y - SCWidth * 0.5
                )
        }
    }
    private func editLocation() {
        let dataStr = "id=" + id + "&name_en=" + name_en + "&latitude=" + latitude + "&longitude=" + longitude + "&altitude=" + altitude + "&type=" + type
        
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
                    let res = try JSONDecoder().decode(PutResult.self, from: data)
                    if(res.nModified == 1) {
                        for i in 0..<locations.count {
                            if(locations[i].id == id) {
                                locations[i] = Location(id: id, name_en: name_en, latitude: Double(latitude)!, longitude: Double(longitude)!, altitude: Double(altitude)!, type: Int(type)!)
                                break
                            }
                        }
                    }
                    id = ""
                } catch let error {
                    print(error)
                }
            }
        }.resume()
    }
}
