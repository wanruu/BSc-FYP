import Foundation
import SwiftUI

struct BusPage: View {
    @State var stops: [Location] = []
    @State var buses: [Bus] = []
    
    @State var showSheet: Bool = false
    @State var sheetType: Int = -1 // 0: bus list, 1: new bus
    
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
        GeometryReader { geometry in
            ZStack {
                // background map
                Image("cuhk-campus-map")
                    .resizable()
                    .frame(width: 3200 * scale, height: 3200 * 25 / 20 * scale, alignment: .center)
                    .position(x: centerX + offset.x, y: centerY + offset.y)
                    .gesture(gesture)
                
                // control button
                VStack(spacing: 0) {
                    Button(action: {
                        sheetType = 0
                        showSheet = true
                    }) {
                        Image(systemName: "list.bullet")
                            .resizable()
                            .frame(width: SCWidth * 0.05, height: SCWidth * 0.04)
                            .padding(SCWidth * 0.03)
                            .padding(.vertical, SCWidth * 0.005)
                    }
                    Divider().frame(width: SCWidth * 0.11)
                    Button(action: {
                        sheetType = 1
                        showSheet = true
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
            }
            .onAppear {
                loadBuses()
                loadLocations()
            }
            .sheet(isPresented: $showSheet) {
                Sheets(stops: $stops, buses: $buses, type: $sheetType)
            }
        }
    }
    private func loadBuses() {
        let url = URL(string: server + "/buses")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                buses = try JSONDecoder().decode([Bus].self, from: data)
            } catch let error {
                print(error)
            }
        }.resume()
    }
    private func loadLocations() {
        let url = URL(string: server + "/locations")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if(error != nil) {
                // showAlert = true
            }
            guard let data = data else { return }
            do {
                let locations = try JSONDecoder().decode([Location].self, from: data)
                for location in locations {
                    if location.type == 1 {
                        stops.append(location)
                    }
                }
            } catch let error {
                // showAlert = true
                print(error)
            }
        }.resume()
    }
}

struct Sheets: View {
    @Binding var stops: [Location]
    @Binding var buses: [Bus]
    @Binding var type: Int
    var body: some View {
        if type == 0 {
            BusList(buses: $buses)
        } else if type == 1 {
            NewBusSheet(stops: $stops, buses: $buses)
        }
    }
}

// bus list sheet
struct BusList: View {
    @Binding var buses: [Bus]
    
    var body: some View {
        NavigationView {
            List {
                ForEach(buses) { bus in
                    VStack(alignment: .leading) {
                        HStack {
                            Text(bus.id).font(.title2)
                            Text(bus.name_en).font(.title2)
                        }
                        
                        HStack {
                            if bus.serviceDay == 0 {
                                Text("Mon - Sat")
                            } else if bus.serviceDay == 1 {
                                Text("Sun & Public Holidays")
                            } else {
                                Text("Teaching days only")
                            }
                            Text(bus.serviceHour)
                        }
                        
                        HStack {
                            Text("Departs hourly at")
                            ForEach(bus.departTime) { value in
                                Text("\(value)")
                            }
                            Text("mins")
                        }
                        VStack {
                            ForEach(bus.special) { rule in
                                HStack {
                                    Text("Buses departing at \(rule.departTime) minutes will")
                                    rule.stop ? nil : Text("not")
                                    Text("stop at \(rule.busStop)")
                                }
                            }
                        }
                    }
                }
                .onDelete(perform: { index in
                    deleteBus(index: index.first!)
                })
            }
            .navigationTitle(Text("Bus List"))
        }
    }
    private func deleteBus(index: Int) {
        let dataStr = "id=" + buses[index].id
        let url = URL(string: server + "/bus")!
        var request = URLRequest(url: url)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"
        request.httpBody = dataStr.data(using: String.Encoding.utf8)
        
        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            guard let data = data else { return }
            do {
                let res = try JSONDecoder().decode(DeleteResult.self, from: data)
                if(res.deletedCount == 1) {
                    buses.remove(at: index)
                }
            } catch let error {
                print(error)
            }
        }.resume()
    }
    
}

// new bus sheet
struct NewBusSheet: View {
    @Binding var stops: [Location]
    @Binding var buses: [Bus]
    
    @State var id = ""
    @State var name_en = ""
    
    @State var serviceDay = 0
    @State var startTime = Date()
    @State var endTime = Date()
    
    @State var departs: [String] = []
    @State var depart: String = ""
    
    @State var chosenStops: [Location] = []
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Basic")) {
                    TextField("ID", text: $id)
                    TextField("Name", text: $name_en)
                }
                
                Section(header: Text("Service")) {
                    Picker(selection: $serviceDay, label: Text("Service Day")) {
                        Text("Mon - Sat").tag(0)
                        Text("Sun & Public Holiday").tag(1)
                        Text("Teaching Days Only").tag(2)
                    }
                    DatePicker("Start at", selection: $startTime, displayedComponents: .hourAndMinute)
                    DatePicker("End at", selection: $endTime, displayedComponents: .hourAndMinute)
                }
                
                Section(header: Text("Departure Hourly at")) {
                    ForEach(departs) { depart in
                        Text(depart)
                    }.onDelete(perform: { index in
                        departs.remove(at: index.first!)
                    })
                    HStack {
                        TextField("", text: $depart).keyboardType(.numberPad)
                        Button(action: {
                            departs.append(depart)
                            depart = ""
                        }) {
                            Text("Add")
                        }.disabled(depart.isEmpty)
                    }
                }
                
                Section(header: Text("Stops")) {
                    ForEach(chosenStops) { stop in
                        Text(stop.name_en)
                    }.onDelete(perform: { index in
                        chosenStops.remove(at: index.first!)
                    })
                    
                    NavigationLink(destination: StopList(stops: $stops, chosenStops: $chosenStops), label: {
                        HStack {
                            Image(systemName: "plus.circle.fill").imageScale(.large).foregroundColor(.green)
                            Text("New")
                        }
                    })
                }
                
                Button(action: {
                    createBus()
                    id = ""
                    name_en = ""
                    serviceDay = 0
                    departs = []
                    chosenStops = []
                }) {
                    HStack {
                        Spacer()
                        Text("Confirm")
                        Spacer()
                    }
                }
                .disabled(id.isEmpty || name_en.isEmpty || departs.isEmpty)
                
            }
            .listStyle(GroupedListStyle())
            .navigationTitle(Text("New Bus"))
        }
    }
    private func createBus() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .none
        dateFormatter.timeStyle = .short
        dateFormatter.locale = NSLocale(localeIdentifier: "en_GB") as Locale
        let start = dateFormatter.string(from: startTime)
        let end = dateFormatter.string(from: endTime)
        
        var stopIds: [String] = []
        for stop in chosenStops {
            stopIds.append(stop._id)
        }

        let data: [String: Any] = [
            "id": id,
            "name_en": name_en,
            "serviceHour": start + "-" + end,
            "serviceDay": serviceDay,
            "stops": stopIds,
            "departTime": departs
        ]
        let jsonData = try? JSONSerialization.data(withJSONObject: data)
        let url = URL(string: server + "/bus")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            do {
                let bus = try JSONDecoder().decode(Bus.self, from: data)
                buses.append(bus)
            } catch let error {
                print(error)
            }
        }.resume()
        
    }
}

struct StopList: View {
    @Environment(\.presentationMode) var mode
    @Binding var stops: [Location]
    @Binding var chosenStops: [Location]
    
    var body: some View {
        VStack {
            
            List {
                ForEach(stops) { stop in
                    Button(action: {
                        chosenStops.append(stop)
                        self.mode.wrappedValue.dismiss()
                    }) {
                        Text(stop.name_en)
                    }
                }
            }
            
        }
    }
}
