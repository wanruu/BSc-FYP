import Foundation
import SwiftUI
import MapKit

/*
struct LocationPage: View {
    // locations data
    @State var locations: [Location] = []
    @State var selectedLoc: Location? = nil // clicked location
    @Binding var current: Coor3D
    
    // control
    @State var showList = false
    @State var showEditWindow = false
    @State var showAddWindow = false
    
    // TODO: add alert of unable to connect to server
    
    var body: some View {
        ZStack {
            LocPageMapView(locations: $locations, selectedLoc: $selectedLoc)
            /*
            
            // add & list button
            VStack(spacing: 0) {
                Button(action: {
                    showList = true
                    showAddWindow = false
                    showEditWindow = false
                }) {
                    Image(systemName: "list.bullet")
                        .resizable()
                        .frame(width: SCWidth * 0.05, height: SCWidth * 0.04)
                        .padding(SCWidth * 0.03)
                        .padding(.vertical, SCWidth * 0.005)
                }
                Divider().frame(width: SCWidth * 0.11)
                Button(action: {
                    showAddWindow = true
                    showList = false
                    showEditWindow = false
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: SCWidth * 0.05, height: SCWidth * 0.05)
                        .padding(SCWidth * 0.03)
                }
            }
            .background(Color.white)
            .cornerRadius(SCWidth * 0.015)
            .shadow(radius: 10)
            .offset(x: SCWidth * 0.38, y: -SCHeight * 0.5 + SCWidth * 0.44)

            // edit window
            if showEditWindow && clickedLoc != nil {
                EditLocWindow(locations: $locations, id: clickedLoc!._id, name_en: clickedLoc!.name_en, latitude: String(clickedLoc!.latitude), longitude: String(clickedLoc!.longitude), altitude: String(clickedLoc!.altitude), type: String(clickedLoc!.type), showing: $showEditWindow)
            }
            
            // add window
            if showAddWindow {
                NewLocWindow(locations: $locations, current: $current, showing: $showAddWindow)
            }
 */
        }
        .onAppear {
            loadLocations()
        }
        
        // sheet: location list
        /*.sheet(isPresented: $showList) {
            LocationList(locations: $locations, clickedLoc: $clickedLoc, showList: $showList, offset: $offset, lastOffset: $lastOffset, scale: $scale, lastScale: $lastScale)
        }*/
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
}

// MARK: - Location List Window
struct LocationList: View {
    @Binding var locations: [Location]
    @Binding var clickedLoc: Location?
    
    @Binding var showList: Bool
    
    @Binding var offset: Offset
    @Binding var lastOffset: Offset
    @Binding var scale: CGFloat
    @Binding var lastScale: CGFloat
    
    var body: some View {
        NavigationView {
            List {
                ForEach(locations) { location in
                    Button(action: {
                        clickedLoc = location
                        // move to center
                        offset.x = -CGFloat((location.longitude - centerLg) * lgScale * 2) * scale
                        offset.y = -CGFloat((centerLa - location.latitude) * laScale * 2) * scale
                        lastOffset = offset
                        showList = false
                    }) {
                        HStack(spacing: SCWidth * 0.04) {
                            Image(systemName: location.type == 0 ? "building.2" : "bus").imageScale(.large)
                            Text(location.name_en)
                            Spacer()
                        }.padding(SCWidth * 0.02).contentShape(Rectangle())
                    }
                    .buttonStyle(MyButtonStyle2(bgColor: CUPurple.opacity(0.8)))
                }
                .onDelete { offsets in
                    let index = offsets.first!
                    deleteLocation(index: index)
                }
            }
            .navigationTitle("Location List")
        }
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


// MARK: - Edit Location Window
struct EditLocWindow: View {
    
    // need to update after editing successfully
    @Binding var locations: [Location]
    
    // for textfields
    @State var id: String = ""
    @State var name_en: String = ""
    @State var latitude: String = ""
    @State var longitude: String = ""
    @State var altitude: String = ""
    @State var type: String = ""
    
    // showing itself or not
    @Binding var showing: Bool
    
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
                VStack(spacing: geometry.size.width * 0.03) {
                    //Text("Edit Location").font(.system(size: 20, weight: .bold, design: .rounded))
                    VStack(alignment: .leading) {
                        TextField("ID", text: $id)
                            .padding(geometry.size.width * 0.02)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.8))
                            .disabled(true)
                            .foregroundColor(.gray)

                        TextField("Name", text: $name_en)
                            .padding(geometry.size.width * 0.02)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.8))
                        TextField("latitude", text: $latitude)
                            .padding(geometry.size.width * 0.02)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.8))
                        TextField("longitude", text: $longitude)
                            .padding(geometry.size.width * 0.02)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.8))
                        TextField("altitude", text: $altitude)
                            .padding(geometry.size.width * 0.02)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.8))
                        TextField("Type", text: $type)
                            .padding(geometry.size.width * 0.02)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.8))
                    }
                    HStack {
                        Button(action: {
                            editLocation()
                            showing = false
                        }) {
                            Text("Submit")
                                .padding(geometry.size.width * 0.03)
                                .frame(width: geometry.size.width * 0.25)
                        }
                        .disabled(Double(latitude) == nil || Double(longitude) == nil || Double(altitude) == nil || Int(type) == nil)
                        .buttonStyle(MyButtonStyle(bgColor: CUPurple, disabled: Double(latitude) == nil || Double(longitude) == nil || Double(altitude) == nil || Int(type) == nil))

                        Button(action: {
                            showing = false
                        }) {
                            Text("Cancel")
                                .padding(geometry.size.width * 0.03)
                                .frame(width: geometry.size.width * 0.25)
                        }
                        .buttonStyle(MyButtonStyle(bgColor: CUPurple, disabled: false))
                    }
                }
                .padding(geometry.size.width * 0.05)
                .frame(width: geometry.size.width * 0.88, alignment: .center)
                .background(Color.white)
                .cornerRadius(5)
            }
        }
    }
    private func editLocation() {
        let data: [String: Any] = [
            "id": id,
            "name_en": name_en,
            "latitude": latitude,
            "longitude": longitude,
            "altitude": altitude,
            "type": type
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: data)
        
        let url = URL(string: server + "/location")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            guard let data = data else { return }
            do {
                let res = try JSONDecoder().decode(PutResult.self, from: data)
                if(res.nModified == 1) {
                    let index = locations.firstIndex(where: {$0._id == id})!
                    locations[index] = Location(_id: id, name_en: name_en, latitude: Double(latitude)!, longitude: Double(longitude)!, altitude: Double(altitude)!, type: Int(type)!)
                }
            } catch let error {
                print(error)
            }
        }.resume()
    }
}

// MARK: - New Location Window
struct NewLocWindow: View {
    // need to update after editing successfully
    @Binding var locations: [Location]
    @Binding var current: Coor3D
    
    @State var locationName: String = ""
    @State var locationType: String = ""
    @Binding var showing: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // gray backgound
                Rectangle()
                    .frame(minWidth: geometry.size.width, maxWidth: .infinity, minHeight: geometry.size.height, maxHeight: .infinity, alignment: .center)
                    .foregroundColor(Color.gray.opacity(0.2))
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showing = false
                    }
                
                // window content
                VStack(spacing: geometry.size.width * 0.05) {
                    Text("New Location").font(.system(size: 20, weight: .bold, design: .rounded))
                    
                    VStack(spacing: geometry.size.width * 0.025) {
                        TextField("Name", text: $locationName)
                            .padding(geometry.size.width * 0.025)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.8))
                        TextField("Type", text: $locationType)
                            .padding(geometry.size.width * 0.025)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.8))
                    }
                    
                    HStack {
                        Button(action: {
                            addLocation()
                            showing = false
                        }) {
                            Text("Confirm")
                                .padding(geometry.size.width * 0.03)
                                .frame(width: geometry.size.width * 0.25)
                        }
                            .disabled(locationName == "" || locationType == "")
                            .buttonStyle(MyButtonStyle(bgColor: CUPurple, disabled: locationName == "" || locationType == ""))
                        Button(action: {
                            showing = false
                        }) {
                            Text("Cancel")
                                .padding(geometry.size.width * 0.03)
                                .frame(width: geometry.size.width * 0.25)
                        }
                            .buttonStyle(MyButtonStyle(bgColor: CUPurple, disabled: false))
                    }
                }
                .padding(.vertical, geometry.size.width * 0.05)
                .padding(.horizontal, geometry.size.width * 0.08)
                .frame(width: geometry.size.width * 0.7, alignment: .center)
                .background(Color.white)
                .cornerRadius(geometry.size.width * 0.03)
            }
        }
    }
    
    private func addLocation() {
        let data: [String: Any] = [
            "name_en": locationName,
            "latitude": current.latitude,
            "longitude": current.longitude,
            "altitude": current.altitude,
            "type": locationType
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: data)
        
        
        let url = URL(string: server + "/location")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if(error != nil) {
                print("error")
            } else {
                guard let data = data else { return }
                do {
                    let location = try JSONDecoder().decode(Location.self, from: data)
                    locations.append(location)
                    locationName = ""
                    locationType = ""
                } catch let error {
                    print(error)
                }
            }
        }.resume()
    }
}

struct LocPageMapView: UIViewRepresentable {
    @Binding var locations: [Location]
    @Binding var selectedLoc: Location?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: centerLa, longitude: centerLg), span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeAnnotations(mapView.annotations)
        for location in locations {
            let ant = MKPointAnnotation()
            ant.coordinate = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            ant.title = location.name_en
            ant.subtitle = location.type == 0 ? "Building" : "Bus stop"
            mapView.addAnnotation(ant)
        }
    }
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: LocPageMapView
        
        init(_ parent: LocPageMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            if annotation.subtitle == "Building" {
                let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "building")
                annotationView.glyphImage = UIImage(systemName: "building.2")
                return annotationView
            } else {
                let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "stop")
                annotationView.glyphImage = UIImage(systemName: "bus")
                return annotationView
            }
        }
        
        
        func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {

        }
        
        func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
            
        }
    }
}
*/

struct LocationPage: View {
    // locations data
    @State var locations: [Location] = []
    @State var clickedLoc: Location? = nil // clicked location
    @Binding var current: Coor3D
    
    // control
    @State var showList = false
    @State var showEditWindow = false
    @State var showAddWindow = false
    
    // TODO: add alert of unable to connect to server
    
    // gesture
    @State var offset: Offset = Offset(x: 0, y: 0)
    @State var lastOffset: Offset = Offset(x: 0, y: 0)
    @State var scale: CGFloat = minZoomOut
    @State var lastScale: CGFloat = minZoomOut
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
            ForEach(locations) { location in
                Button(action: {
                    clickedLoc = location
                    showEditWindow = true
                }) {
                    if clickedLoc != nil && location.id == clickedLoc!.id {
                        Image("location-white")
                            .resizable()
                            .frame(width: SCWidth * 0.1, height: SCWidth * 0.1, alignment: .center)
                    } else if location.type == 0 {
                        Image("location-purple")
                            .resizable()
                            .frame(width: SCWidth * 0.1, height: SCWidth * 0.1, alignment: .center)
                    } else {
                        Image("location-yellow")
                            .resizable()
                            .frame(width: SCWidth * 0.1, height: SCWidth * 0.1, alignment: .center)
                    }
                }
                .position(
                    x: centerX + CGFloat((location.longitude - centerLg)*lgScale*2) * scale + offset.x,
                    y: centerY + CGFloat((centerLa - location.latitude)*laScale*2) * scale + offset.y - SCWidth * 0.05
                )
            }
            
            // add & list button
            VStack(spacing: 0) {
                Button(action: {
                    showList = true
                    showAddWindow = false
                    showEditWindow = false
                }) {
                    Image(systemName: "list.bullet")
                        .resizable()
                        .frame(width: SCWidth * 0.05, height: SCWidth * 0.04)
                        .padding(SCWidth * 0.03)
                        .padding(.vertical, SCWidth * 0.005)
                }
                Divider().frame(width: SCWidth * 0.11)
                Button(action: {
                    showAddWindow = true
                    showList = false
                    showEditWindow = false
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: SCWidth * 0.05, height: SCWidth * 0.05)
                        .padding(SCWidth * 0.03)
                }
            }
            .background(Color.white)
            .cornerRadius(SCWidth * 0.015)
            .shadow(radius: 10)
            .offset(x: SCWidth * 0.38, y: -SCHeight * 0.5 + SCWidth * 0.44)

            // edit window
            if showEditWindow && clickedLoc != nil {
                EditLocWindow(locations: $locations, id: clickedLoc!._id, name_en: clickedLoc!.name_en, latitude: String(clickedLoc!.latitude), longitude: String(clickedLoc!.longitude), altitude: String(clickedLoc!.altitude), type: String(clickedLoc!.type), showing: $showEditWindow)
            }
            
            // add window
            if showAddWindow {
                NewLocWindow(locations: $locations, current: $current, showing: $showAddWindow)
            }
        }
        .onAppear {
            loadLocations()
        }
        // gesture
        .highPriorityGesture(gesture)
        
        // sheet: location list
        .sheet(isPresented: $showList) {
            LocationList(locations: $locations, clickedLoc: $clickedLoc, showList: $showList, offset: $offset, lastOffset: $lastOffset, scale: $scale, lastScale: $lastScale)
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
}

// MARK: - Location List Window
struct LocationList: View {
    @Binding var locations: [Location]
    @Binding var clickedLoc: Location?
    
    @Binding var showList: Bool
    
    @Binding var offset: Offset
    @Binding var lastOffset: Offset
    @Binding var scale: CGFloat
    @Binding var lastScale: CGFloat
    
    var body: some View {
        NavigationView {
            List {
                ForEach(locations) { location in
                    Button(action: {
                        clickedLoc = location
                        // move to center
                        offset.x = -CGFloat((location.longitude - centerLg) * lgScale * 2) * scale
                        offset.y = -CGFloat((centerLa - location.latitude) * laScale * 2) * scale
                        lastOffset = offset
                        showList = false
                    }) {
                        HStack(spacing: SCWidth * 0.04) {
                            Image(systemName: location.type == 0 ? "building.2" : "bus").imageScale(.large)
                            Text(location.name_en)
                            Spacer()
                        }.padding(SCWidth * 0.02).contentShape(Rectangle())
                    }
                    .buttonStyle(MyButtonStyle2(bgColor: CUPurple.opacity(0.8)))
                }
                .onDelete { offsets in
                    let index = offsets.first!
                    deleteLocation(index: index)
                }
            }
            .navigationTitle("Location List")
        }
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


// MARK: - Edit Location Window
struct EditLocWindow: View {
    
    // need to update after editing successfully
    @Binding var locations: [Location]
    
    // for textfields
    @State var id: String = ""
    @State var name_en: String = ""
    @State var latitude: String = ""
    @State var longitude: String = ""
    @State var altitude: String = ""
    @State var type: String = ""
    
    // showing itself or not
    @Binding var showing: Bool
    
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
                VStack(spacing: geometry.size.width * 0.03) {
                    //Text("Edit Location").font(.system(size: 20, weight: .bold, design: .rounded))
                    VStack(alignment: .leading) {
                        TextField("ID", text: $id)
                            .padding(geometry.size.width * 0.02)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.8))
                            .disabled(true)
                            .foregroundColor(.gray)

                        TextField("Name", text: $name_en)
                            .padding(geometry.size.width * 0.02)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.8))
                        TextField("latitude", text: $latitude)
                            .padding(geometry.size.width * 0.02)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.8))
                        TextField("longitude", text: $longitude)
                            .padding(geometry.size.width * 0.02)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.8))
                        TextField("altitude", text: $altitude)
                            .padding(geometry.size.width * 0.02)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.8))
                        TextField("Type", text: $type)
                            .padding(geometry.size.width * 0.02)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.8))
                    }
                    HStack {
                        Button(action: {
                            editLocation()
                            showing = false
                        }) {
                            Text("Submit")
                                .padding(geometry.size.width * 0.03)
                                .frame(width: geometry.size.width * 0.25)
                        }
                        .disabled(Double(latitude) == nil || Double(longitude) == nil || Double(altitude) == nil || Int(type) == nil)
                        .buttonStyle(MyButtonStyle(bgColor: CUPurple, disabled: Double(latitude) == nil || Double(longitude) == nil || Double(altitude) == nil || Int(type) == nil))

                        Button(action: {
                            showing = false
                        }) {
                            Text("Cancel")
                                .padding(geometry.size.width * 0.03)
                                .frame(width: geometry.size.width * 0.25)
                        }
                        .buttonStyle(MyButtonStyle(bgColor: CUPurple, disabled: false))
                    }
                }
                .padding(geometry.size.width * 0.05)
                .frame(width: geometry.size.width * 0.88, alignment: .center)
                .background(Color.white)
                .cornerRadius(5)
            }
        }
    }
    private func editLocation() {
        let data: [String: Any] = [
            "id": id,
            "name_en": name_en,
            "latitude": latitude,
            "longitude": longitude,
            "altitude": altitude,
            "type": type
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: data)
        
        let url = URL(string: server + "/location")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            guard let data = data else { return }
            do {
                let res = try JSONDecoder().decode(PutResult.self, from: data)
                if(res.nModified == 1) {
                    let index = locations.firstIndex(where: {$0._id == id})!
                    locations[index] = Location(_id: id, name_en: name_en, latitude: Double(latitude)!, longitude: Double(longitude)!, altitude: Double(altitude)!, type: Int(type)!)
                }
            } catch let error {
                print(error)
            }
        }.resume()
    }
}

// MARK: - New Location Window
struct NewLocWindow: View {
    // need to update after editing successfully
    @Binding var locations: [Location]
    @Binding var current: Coor3D
    
    @State var locationName: String = ""
    @State var locationType: String = ""
    @Binding var showing: Bool
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // gray backgound
                Rectangle()
                    .frame(minWidth: geometry.size.width, maxWidth: .infinity, minHeight: geometry.size.height, maxHeight: .infinity, alignment: .center)
                    .foregroundColor(Color.gray.opacity(0.2))
                    .edgesIgnoringSafeArea(.all)
                    .onTapGesture {
                        showing = false
                    }
                
                // window content
                VStack(spacing: geometry.size.width * 0.05) {
                    Text("New Location").font(.system(size: 20, weight: .bold, design: .rounded))
                    
                    VStack(spacing: geometry.size.width * 0.025) {
                        TextField("Name", text: $locationName)
                            .padding(geometry.size.width * 0.025)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.8))
                        TextField("Type", text: $locationType)
                            .padding(geometry.size.width * 0.025)
                            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.8))
                    }
                    
                    HStack {
                        Button(action: {
                            addLocation()
                            showing = false
                        }) {
                            Text("Confirm")
                                .padding(geometry.size.width * 0.03)
                                .frame(width: geometry.size.width * 0.25)
                        }
                            .disabled(locationName == "" || locationType == "")
                            .buttonStyle(MyButtonStyle(bgColor: CUPurple, disabled: locationName == "" || locationType == ""))
                        Button(action: {
                            showing = false
                        }) {
                            Text("Cancel")
                                .padding(geometry.size.width * 0.03)
                                .frame(width: geometry.size.width * 0.25)
                        }
                            .buttonStyle(MyButtonStyle(bgColor: CUPurple, disabled: false))
                    }
                }
                .padding(.vertical, geometry.size.width * 0.05)
                .padding(.horizontal, geometry.size.width * 0.08)
                .frame(width: geometry.size.width * 0.7, alignment: .center)
                .background(Color.white)
                .cornerRadius(geometry.size.width * 0.03)
            }
        }
    }
    
    private func addLocation() {
        let data: [String: Any] = [
            "name_en": locationName,
            "latitude": current.latitude,
            "longitude": current.longitude,
            "altitude": current.altitude,
            "type": locationType
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: data)
        
        
        let url = URL(string: server + "/location")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData

        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if(error != nil) {
                print("error")
            } else {
                guard let data = data else { return }
                do {
                    let location = try JSONDecoder().decode(Location.self, from: data)
                    locations.append(location)
                    locationName = ""
                    locationType = ""
                } catch let error {
                    print(error)
                }
            }
        }.resume()
    }
}

