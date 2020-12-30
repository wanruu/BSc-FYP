/* MARK: Location Page - a list of locations */

import Foundation
import SwiftUI

struct LocationPage: View {
    // locations data
    @Binding var locations: [Location]
    
    // sheet
    @State var showList = false

    // clicked location
    @State var clickedIndex: Int = -1
    
    // edit location textfield
    @State var name_en: String = ""
    @State var latitude: String = ""
    @State var longitude: String = ""
    @State var altitude: String = ""
    @State var type: String = ""
    
    // gesture
    @State var offset: Offset = Offset(x: 0, y: 0)
    @State var lastOffset = Offset(x: 0, y: 0)
    @State var scale: CGFloat = minZoomOut
    @State var lastScale = minZoomOut
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
    }
    
    var body: some View {
        ZStack {
            // background map
            Image("cuhk-campus-map")
            .resizable()
            .frame(width: 3200 * scale, height: 3200 * 25 / 20 * scale, alignment: .center)
            .position(x: centerX + offset.x, y: centerY + offset.y)
            // locations
            LocationsView(locations: $locations, clickedIndex: $clickedIndex, name_en: $name_en, latitude: $latitude, longitude: $longitude, altitude: $altitude, type: $type, offset: $offset, scale: $scale)
        }
        .onAppear {
            loadLocations()
        }
        // gesture
        .contentShape(Rectangle())
        .highPriorityGesture(gesture)
        // navigation bar
        .navigationTitle("Location")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(action: {showList = true}) {Image(systemName: "list.bullet").imageScale(.large)} )
        // sheet: list
        .sheet(isPresented: $showList) {
            Image(systemName: "line.horizontal.3")
                .foregroundColor(Color.gray)
                .padding()
                .frame(width: SCWidth)
            List {
                ForEach(locations) { location in
                    let i = locations.firstIndex(of: location)!
                    Button(action: {
                        clickedIndex = i
                        name_en = locations[i].name_en
                        latitude = String(locations[i].latitude)
                        longitude = String(locations[i].longitude)
                        altitude = String(locations[i].altitude)
                        type = String(locations[i].type)
                        showList = false
                        // move selected location to center
                        offset.x = CGFloat((centerLg - locations[i].longitude)*lgScale*2) * scale
                        offset.y = CGFloat((locations[i].latitude - centerLa)*laScale*2) * scale
                        lastOffset = offset
                    }) {
                        HStack {
                            Image(systemName: locations[i].type == 0 ? "building.2" : "bus")
                            VStack(alignment: .leading) {
                                Text(locations[i].name_en).font(.headline)
                                Text("(\(locations[i].latitude), \(locations[i].longitude), \(locations[i].altitude)").font(.subheadline)
                            }
                        }
                    }
                }
                .onDelete { offsets in
                    let index = offsets.first!
                    deleteLocation(index: index)
                }
            }
        }
    }
    
    private func loadLocations() {
        let url = URL(string: server + "/locations")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if(error != nil) {
                // showAlert = true
            }
            guard let data = data else { return }
            do {
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch let error {
                // showAlert = true
                print(error)
            }
        }.resume()
    }
    
    private func deleteLocation(index: Int) {
        let dataStr = "id=" + locations[index].id
        let url = URL(string: server + "/location")!
        var request = URLRequest(url: url)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"
        request.httpBody = dataStr.data(using: String.Encoding.utf8)
        
        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            guard let data = data else { return }
            do {
                let res = try JSONDecoder().decode(DeleteResult.self, from: data)
                if(res.deletedCount == 1) {
                    locations.remove(at: index)
                }
            } catch let error {
                print(error)
            }
        }.resume()
    }
}

/*
struct EditLocWindow: View {
    @State var id: String
    @State var name_en: String
    @State var latitude: String
    @State var longitude: String
    @State var altitude: String
    @State var type: String
    var body: some View {
        
    }
}
*/
struct LocationView: View {
    @Binding var location: Location
    @State var name_en: String
    @State var latitude: String
    @State var longitude: String
    @State var altitude: String
    @State var type: String
    
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    @State var showing = false
    var body: some View {
        ZStack {
            Button(action: {
                showing = !showing
            }) {
                Image(location.type == 0 ? "location-purple" : "location-yellow")
                .resizable()
                .frame(width: SCWidth * 0.1, height: SCWidth * 0.1, alignment: .center)
            }
            .position(
                x: centerX + CGFloat((location.longitude - centerLg)*lgScale*2) * scale + offset.x,
                y: centerY + CGFloat((centerLa - location.latitude)*laScale*2) * scale + offset.y - SCWidth * 0.05
            )
        }
    }
}

struct LocationsView: View {
    // location data
    @Binding var locations: [Location]
    // clicked location index
    @Binding var clickedIndex: Int
    // textfield
    @Binding var name_en: String
    @Binding var latitude: String
    @Binding var longitude: String
    @Binding var altitude: String
    @Binding var type: String
    
    // gesture
    @Binding var offset: Offset
    @Binding var scale: CGFloat

    var body: some View {
        ZStack {
            // landmark
            ForEach(locations) { location in
                let i = locations.firstIndex(of: location)!
                // let i = 0
                Button(action: {
                    if(clickedIndex == i) {
                        clickedIndex = -1
                    } else {
                        clickedIndex = i
                        name_en = locations[i].name_en
                        latitude = String(locations[i].latitude)
                        longitude = String(locations[i].longitude)
                        altitude = String(locations[i].altitude)
                        type = String(locations[i].type)
                    }
                }) {
                    Image(locations[i].type == 0 ? "location-purple" : "location-yellow")
                    .resizable()
                        .frame(width: SCWidth * 0.1, height: SCWidth * 0.1, alignment: .center)
                }
                .position(
                    x: centerX + CGFloat((locations[i].longitude - centerLg)*lgScale*2) * scale + offset.x,
                    y: centerY + CGFloat((centerLa - locations[i].latitude)*laScale*2) * scale + offset.y - SCWidth * 0.05
                )
            }
            // textfield
            if clickedIndex != -1 {
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
                            clickedIndex = -1
                        }) { Text("Cancel") }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.9))
                .cornerRadius(10)
                .frame(width: SCWidth * 0.7)
                .position(
                    x: centerX + CGFloat((locations[clickedIndex].longitude - centerLg)*lgScale*2) * scale + offset.x,
                    y: centerY + CGFloat((centerLa - locations[clickedIndex].latitude)*laScale*2) * scale + offset.y - SCWidth * 0.5
                )
            }
        }
    }
    private func editLocation() {
        let dataStr = "id=" + locations[clickedIndex].id + "&name_en=" + name_en + "&latitude=" + latitude + "&longitude=" + longitude + "&altitude=" + altitude + "&type=" + type
        
        let url = URL(string: server + "/location")!
        var request = URLRequest(url: url)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        request.httpBody = dataStr.data(using: String.Encoding.utf8)

        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            guard let data = data else { return }
            do {
                let res = try JSONDecoder().decode(PutResult.self, from: data)
                if(res.nModified == 1) {
                    for i in 0..<locations.count {
                        if(i == clickedIndex) {
                            // TODO: why unable to update
                            locations[i].name_en = name_en
                            locations[i].latitude = Double(latitude)!
                            locations[i].longitude = Double(longitude)!
                            print(locations[i].altitude)
                            locations[i].altitude = Double(altitude)!
                            print(locations[i].altitude)
                            locations[i].type = Int(type)!
                            print(altitude)
                            print(locations[i])
                            break
                        }
                    }
                }
                clickedIndex = -1
            } catch let error {
                print(error)
            }
        }.resume()
    }
}
