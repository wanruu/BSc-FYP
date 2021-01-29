import Foundation
import SwiftUI

struct BusPage: View {
    @State var locations: [Location] = []
    @State var buses: [Bus] = []
    @State var routes: [Route] = []
    @State var results: [Route] = []
    @State var resultIndex: Int = 0
    
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
        ZStack {
            // background map
            Image("cuhk-campus-map")
                .resizable()
                .frame(width: 3200 * scale, height: 3200 * 25 / 20 * scale, alignment: .center)
                .position(x: centerX + offset.x, y: centerY + offset.y)
                .gesture(gesture)
            
            
            RoutesView(routes: $results, routeIndex: $resultIndex, offset: $offset, scale: $scale)
            
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
            
            SearchSheet(locations: $locations, routes: $routes, results: $results, resultIndex: $resultIndex)
        }
        .onAppear {
            loadBuses()
            loadLocations()
            loadRoutes()
        }
        .sheet(isPresented: $showSheet) {
            Sheets(locations: $locations, buses: $buses, type: $sheetType)
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
            guard let data = data else { return }
            do {
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch let error {
                print(error)
            }
        }.resume()
    }
    private func loadRoutes() {
        let url = URL(string: server + "/routes")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                routes = try JSONDecoder().decode([Route].self, from: data)
            } catch let error {
                print(error)
            }
        }.resume()
    }
}

struct RoutesView: View {
    @Binding var routes: [Route]
    @Binding var routeIndex: Int
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    var body: some View {
        ZStack {
            ForEach(routes) { route in
                Path { p in
                    for i in 0..<route.points.count {
                        let point = CGPoint(
                            x: centerX + CGFloat((route.points[i].longitude - centerLg) * lgScale * 2) * scale + offset.x,
                            y: centerY + CGFloat((centerLa - route.points[i].latitude) * laScale * 2) * scale + offset.y)
                        if i == 0 {
                            p.move(to: point)
                        } else {
                            p.addLine(to: point)
                        }
                    }
                }
                .stroke(Color.gray, lineWidth: 4)
            }
            ForEach(routes) { route in
                if routes.firstIndex(of: route)! == routeIndex {
                    Path { p in
                        for i in 0..<route.points.count {
                            let point = CGPoint(
                                x: centerX + CGFloat((route.points[i].longitude - centerLg) * lgScale * 2) * scale + offset.x,
                                y: centerY + CGFloat((centerLa - route.points[i].latitude) * laScale * 2) * scale + offset.y)
                            if i == 0 {
                                p.move(to: point)
                            } else {
                                p.addLine(to: point)
                            }
                        }
                    }
                    .stroke(CUPurple, lineWidth: 4)
                }
            }
        }
    }
}

// MARK: - Sheet

// search sheet
struct SearchSheet: View {
    // input for route planning
    @Binding var locations: [Location]
    @Binding var routes: [Route]
    @State var startStop: Location? = nil
    @State var endStop: Location? = nil
    
    // output of route planning
    @Binding var results: [Route]
    @Binding var resultIndex: Int
    
    @State var page: Int = 0
    
    // gesture
    @State var lastOffset: CGFloat = 0
    @State var offset: CGFloat = 0
    
    var body: some View {
        GeometryReader { geo in
            VStack {
                Spacer()
                
                // sheet content
                VStack {
                    Image(systemName: "line.horizontal.3").foregroundColor(.gray).padding()
                        
                    switch page {
                        // search area
                        case 0:
                            VStack(alignment: .leading) {
                                Text(startStop == nil ? "From" : startStop!.name_en)
                                    .foregroundColor(startStop == nil ? .gray : .black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                                    .padding()
                                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray, lineWidth: 0.5))
                                    .onTapGesture {
                                        page = 1
                                    }
                                Text(endStop == nil ? "To" : endStop!.name_en)
                                    .foregroundColor(endStop == nil ? .gray : .black)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(Rectangle())
                                    .padding()
                                    .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray, lineWidth: 0.5))
                                    .onTapGesture {
                                        page = 2
                                    }
                                
                                Text("\(results.count) result(s)").padding()
                                HStack {
                                    Button(action: {
                                        resultIndex -= 1
                                    }) {
                                        Image(systemName: "arrow.left")
                                    }.disabled(resultIndex == 0)
                                    Spacer()
                                    
                                    Button(action: {
                                        uploadBusRoute()
                                    }) {
                                        Text("Save as a bus route").padding()
                                    }
                                    .disabled(resultIndex >= results.count)
                                    
                                    Spacer()
                                    Button(action: {
                                        resultIndex += 1
                                    }) {
                                        Image(systemName: "arrow.right")
                                    }.disabled(resultIndex >= results.count - 1)
                                }.padding()
                            }
                            .padding(.horizontal)
                            .onAppear {
                                findAllRoutes()
                            }
                    
                        // start stop list
                        case 1: StopListForSearch(locations: $locations, chosenStop: $startStop, page: $page)
                        
                        // end stop list
                        default: StopListForSearch(locations: $locations, chosenStop: $endStop, page: $page)
                    }
                }
                .frame(width: geo.size.width, height: geo.size.height, alignment: .top)
                .background(RoundedCorners(color: .white, tl: 15, tr: 15, bl: 0, br: 0))
                .offset(y: offset)
                .animation(.easeInOut)
                .clipped()
                .shadow(radius: 10)
                
            }
            .ignoresSafeArea(.container, edges: .bottom)
            .gesture(DragGesture()
                .onChanged{ value in
                    if lastOffset + value.location.y - value.startLocation.y < 0 {
                        offset = 0
                    } else {
                        offset = lastOffset + value.location.y - value.startLocation.y
                    }
                }
                .onEnded{ _ in
                    lastOffset = offset
            })
            
        }
    }
    
    private func findAllRoutes() {
        guard startStop != nil && endStop != nil else {
            return
        }
        
        results = []
        resultIndex = 0
        
        let route = Route(_id: "", startLoc: nil, endLoc: nil, points: [], dist: 0, type: 1)
        checkNextRoute(curResult: route)
        
        for i in 0..<results.count {
            results[i]._id = String(i)
        }
       
    }
    
    // DFS
    private func checkNextRoute(curResult: Route) {
        if curResult.startLoc == startStop && curResult.endLoc == endStop {
            results.append(curResult)
            return
        }
        
        if curResult.startLoc == nil { // to find the first route
            for i in 0..<routes.count {
                if routes[i].startLoc == startStop {
                    var curResult = curResult
                    curResult.startLoc = routes[i].startLoc
                    curResult.endLoc = routes[i].endLoc
                    curResult.points = routes[i].points
                    curResult.dist = routes[i].dist
                    checkNextRoute(curResult: curResult)
                } else if routes[i].endLoc == startStop {
                    var curResult = curResult
                    curResult.startLoc = routes[i].endLoc
                    curResult.endLoc = routes[i].startLoc
                    curResult.points = routes[i].points.reversed()
                    curResult.dist = routes[i].dist
                    checkNextRoute(curResult: curResult)
                }
            }
        } else {
            for i in 0..<routes.count {
                if routes[i].startLoc == curResult.endLoc {
                    if isOverlapped(points1: curResult.points, points2: routes[i].points) { continue }
                    var curResult = curResult
                    curResult.endLoc = routes[i].endLoc
                    curResult.points += routes[i].points
                    curResult.dist += routes[i].dist
                    checkNextRoute(curResult: curResult)
                } else if routes[i].endLoc == curResult.endLoc {
                    if isOverlapped(points1: curResult.points, points2: routes[i].points) { continue }
                    var curResult = curResult
                    curResult.endLoc = routes[i].startLoc
                    curResult.points += routes[i].points.reversed()
                    curResult.dist += routes[i].dist
                    checkNextRoute(curResult: curResult)
                }
            }
        }
    }
    
    private func isOverlapped(points1: [Coor3D], points2: [Coor3D]) -> Bool {
        var count = 0
        for p in points1 {
            if points2.contains(p) {
                count += 1
            }
            if count >= 2 {
                return true
            }
        }
        return false
    }
    
    private func uploadBusRoute() {
        
    }
}



struct StopListForSearch: View {
    @State var text: String = ""
    @Binding var locations: [Location]
    @Binding var chosenStop: Location?
    @Binding var page: Int
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "arrow.left").onTapGesture {
                    page = 0
                }
                TextField("To", text: $text)
                text.isEmpty ? nil : Image(systemName: "xmark").onTapGesture {
                    text = ""
                }
            }
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 6).stroke(Color.gray, lineWidth: 0.5))
            ScrollView(.vertical, showsIndicators: false) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(locations) { location in
                        if location.type == 1 && ( text.isEmpty || location.name_en.lowercased().contains(text.lowercased())) {
                            Button(action: {
                                chosenStop = location
                                page = 0
                            }) {
                                Text(location.name_en).frame(maxWidth: .infinity, alignment: .leading).padding()
                            }.buttonStyle(MyButtonStyle2(bgColor: Color.gray.opacity(0.5)))
                            Divider()
                        }
                    }
                }
            }
        }.padding(.horizontal)
    }
}

struct Sheets: View {
    @Binding var locations: [Location]
    @Binding var buses: [Bus]
    @Binding var type: Int
    var body: some View {
        if type == 0 {
            BusListSheet(buses: $buses)
        } else if type == 1 {
            NewBusSheet(locations: $locations, buses: $buses)
        }
    }
}

// bus list sheet
struct BusListSheet: View {
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
    @Binding var locations: [Location]
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
                    
                    NavigationLink(destination: StopList(locations: $locations, chosenStops: $chosenStops), label: {
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
    @Binding var locations: [Location]
    @Binding var chosenStops: [Location]
    
    var body: some View {
        VStack {
            List {
                ForEach(locations) { location in
                    if location.type == 1 {
                        Button(action: {
                            chosenStops.append(location)
                            self.mode.wrappedValue.dismiss()
                        }) {
                            Text(location.name_en)
                        }
                    }
                }
            }
        }
    }
}
