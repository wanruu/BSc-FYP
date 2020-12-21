/* MARK: Location Page - a list of locations */

import Foundation
import SwiftUI

struct LocationPage: View {
    @Binding var locations: [Location]
    @State var showedLocation: Location? = nil
    // gesture
    @State var offset: Offset = Offset(x: 0, y: 0)
    @State var lastOffset = Offset(x: 0, y: 0)
    @State var scale: CGFloat = minZoomOut
    @State var lastScale = minZoomOut
    // sheet & alert
    @State var showList = false

    var body: some View {
        ZStack {
            // map
            Image("cuhk-campus-map")
            .resizable()
            .frame(width: 3200 * scale, height: 3200 * 25 / 20 * scale, alignment: .center)
            .position(x: centerX + offset.x, y: centerY + offset.y)
            // locations
            LocationsView(locations: $locations, showedLocation: $showedLocation, offset: $offset, scale: $scale)
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
                            showedLocation = location
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
                    }.onDelete { offsets in
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
    @Binding var showedLocation: Location?
    
    @Binding var offset: Offset
    @Binding var scale: CGFloat

    var body: some View {
        ZStack {
            ForEach(locations) { location in
                LocationView(location: location, showedLocation: $showedLocation, offset: $offset, scale: $scale)
            }
            showedLocation != nil ?
                Text(showedLocation!.name_en)
                .padding(SCWidth * 0.01)
                .background(Color.white.opacity(0.8))
                .cornerRadius(5)
                .position(
                    x: centerX + CGFloat((showedLocation!.longitude - centerLg)*lgScale*2) * scale + offset.x,
                    y: centerY + CGFloat((centerLa - showedLocation!.latitude)*laScale*2) * scale + offset.y
                ) : nil
        }
    }
}

struct LocationView: View {
    @State var location: Location
    @Binding var showedLocation: Location?
    
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    var body: some View {
        Button(action: {
            if(showedLocation == location) {
                showedLocation = nil
            } else {
                showedLocation = location
            }
        }) {
            location == showedLocation ?
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
}

/*
struct EditLocationPrompt<Presenting>: View where Presenting: View {
    @Binding var isShowing: Bool
    
    @State var name: String
    @State var latitude: String
    @State var longitude: String
    @State var altitude: String
    @State var type: String
    
    let presenting: Presenting
    
    var body: some View {
        GeometryReader { _ in
            ZStack {
                presenting.disabled(isShowing)
                VStack {
                    Text("Edit Location").bold().padding()
                    HStack {
                        Text("Name: ")
                        TextField("Name", text: $name).textFieldStyle(RoundedBorderTextFieldStyle()).padding(.horizontal)
                    }
                    HStack {
                        Text("Latitude: ")
                        TextField("Latitude", text: $latitude).textFieldStyle(RoundedBorderTextFieldStyle()).padding(.horizontal)
                    }
                    HStack {
                        Text("Longitude: ")
                        TextField("Longitude", text: $longitude).textFieldStyle(RoundedBorderTextFieldStyle()).padding(.horizontal)
                    }
                    HStack {
                        Text("Altitude: ")
                        TextField("Altitude", text: $altitude).textFieldStyle(RoundedBorderTextFieldStyle()).padding(.horizontal)
                    }
                    HStack {
                        Text("Type: ")
                        TextField("Type", text: $type).textFieldStyle(RoundedBorderTextFieldStyle()).padding(.horizontal)
                    }
                    
                    Divider()
                    HStack {
                        Button(action: {
                            withAnimation {
                                addLocation()
                                hideKeyboard()
                                isShowing.toggle()
                            }
                        }) {
                            Text("Confirm")
                        }
                        .padding(.horizontal, SCWidth * 0.08)
                        // TODO: .disabled()
                        
                        Divider()
                        Button(action: {
                            withAnimation {
                                isShowing.toggle()
                                hideKeyboard()
                            }
                        }) {
                            Text("Cancel")
                        }.padding(.horizontal, SCWidth * 0.08)
                    }
                    .frame(
                        width: SCWidth * 0.7,
                        height: SCHeight * 0.055
                    )
                }
                .background(Color(red: 0.97, green: 0.97, blue: 0.97))
                .frame(
                    width: SCWidth * 0.7,
                    height: SCHeight * 0.7
                )
                .cornerRadius(50)
                .opacity(self.isShowing ? 1 : 0)
                .offset(x: 0, y: -SCHeight * 0.1)
            }
        }
    }
    
    private func editLocation() {
        // data
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
                        // TODO
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

extension View {
    func newLocationPrompt(isShowing: Binding<Bool>, name: String, latitude: String, longitude: String, altitude: String, type: String) -> some View {
        withAnimation {
            EditLocationPrompt(isShowing: isShowing, name: name, latitude: latitude, longitude: longitude, altitude: altitude, type: type, presenting: self)
        }
    }
}
*/
