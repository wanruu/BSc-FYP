import SwiftUI

struct NewRouteView: View {
    @Binding var locations: [Location]
    @Binding var routes: [Route]
    
    // input
    @State var startLoc: Location? = nil
    @State var endLoc: Location? = nil
    
    // output
    @State var newRoutes: [Route] = []
    @State var selectedRoute: Route? = nil
    
    // showing control
    @State var showStartList = false
    @State var showEndList = false
    
    @Binding var showing: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "chevron.backward").contentShape(Rectangle()).onTapGesture { showing.toggle() }
                VStack {
                    HStack {
                        NavigationLink(destination: StopListSingleView(locations: $locations, chosenStop: $startLoc, placeholder: "From", text: startLoc?.nameEn ?? "", showing: $showStartList), isActive: $showStartList) {
                            startLoc == nil ?
                                Text("Form").foregroundColor(.gray).frame(maxWidth: .infinity, alignment: .leading) :
                                Text(startLoc!.nameEn).foregroundColor(.black).frame(maxWidth: .infinity, alignment: .leading)
                        }
                        startLoc == nil ? nil : Image(systemName: "xmark").contentShape(Rectangle()).onTapGesture { startLoc = nil }
                    }
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.5))
                    
                    HStack {
                        NavigationLink(destination: StopListSingleView(locations: $locations, chosenStop: $endLoc, placeholder: "To", text: endLoc?.nameEn ?? "", showing: $showEndList), isActive: $showEndList) {
                            endLoc == nil ?
                                Text("To").foregroundColor(.gray).frame(maxWidth: .infinity, alignment: .leading) :
                                Text(endLoc!.nameEn).foregroundColor(.black).frame(maxWidth: .infinity, alignment: .leading)
                        }
                        endLoc == nil ? nil : Image(systemName: "xmark").contentShape(Rectangle()).onTapGesture { endLoc = nil }
                    }
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.5))
                }
                Image(systemName: "arrow.up.arrow.down")
                    .imageScale(.large)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        let tmp = endLoc
                        endLoc = startLoc
                        startLoc = tmp
                        searchForRoutes()
                    }
            }.padding()
            
            Divider()
            
            RouteMapView(route: $selectedRoute)
            
            Divider()
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 0) {
                    
                    Text("In database").font(.system(size: 20, weight: .bold, design: .rounded)).padding()
                    Divider()
                    
                    ForEach(routes) { route in
                        if route.type == RouteType.bus && route.startLoc == startLoc && route.endLoc == endLoc {
                            HStack(spacing: 15) {
                                VStack(alignment: .leading) {
                                    Text("ID: \(route.id)")
                                    Text("Distance: \(route.dist) m")
                                }
                                Spacer()
                                if route == selectedRoute {
                                    Image(systemName: "checkmark").foregroundColor(.green)
                                }
                                Image(systemName: "trash")
                                    .foregroundColor(.red)
                                    .contentShape(Rectangle())
                                    .onTapGesture {
                                        deleteRoute(route: route)
                                        selectedRoute = newRoutes.first!
                                    }
                            }
                            .padding()
                            .contentShape(Rectangle())
                            .onTapGesture { selectedRoute = route }
                            Divider()
                        }
                    }
                    if routes.filter({ $0.type == RouteType.bus && $0.startLoc == startLoc && $0.endLoc == endLoc}).isEmpty {
                        Text("No results.").font(.system(size: 15)).italic().padding().foregroundColor(.gray)
                        Divider()
                    }
                    
                    Text("New").font(.system(size: 20, weight: .bold, design: .rounded)).padding()
                    Divider()
                    
                    ForEach(newRoutes) { route in
                        HStack {
                            VStack(alignment: .leading) {
                                Text("ID: \(route.id)")
                                Text("Distance: \(route.dist) m")
                            }
                            Spacer()
                            if route == selectedRoute {
                                Image(systemName: "checkmark").foregroundColor(.green)
                            }
                        }
                        .padding()
                        .contentShape(Rectangle())
                        .onTapGesture { selectedRoute = route }
                        Divider()
                    }
                    
                    if newRoutes.isEmpty {
                        Text("No results.").font(.system(size: 15)).italic().padding().foregroundColor(.gray)
                        Divider()
                    }
                    
                    let disabled = selectedRoute == nil || newRoutes.first(where: { $0.id == selectedRoute!.id }) == nil
                    Button(action: { uploadRoute() }) {
                        Text("Save as a bus route")
                            .padding()
                            .frame(maxWidth: .infinity)
                    }
                    .cornerRadius(5)
                    .buttonStyle(ShrinkButtonStyle(bgColor: disabled ? Color.gray.opacity(0.3) : CU_PALE_YELLOW))
                    .disabled(disabled)
                    .padding()
                }
            }
        }
        .onChange(of: startLoc) { _ in
            searchForRoutes()
        }
        .onChange(of: endLoc) { _ in
            searchForRoutes()
        }
        .navigationBarHidden(true)
        //.navigationBarTitle(NSLocalizedString("Generate routes", comment: ""), displayMode: .inline)

    }
    
    private func deleteRoute(route: Route) {
        let data = ["id": route.id]
        let jsonData = try? JSONSerialization.data(withJSONObject: data)
        let url = URL(string: server + "/route")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            do {
                let res = try JSONDecoder().decode(DeleteResult.self, from: data)
                if res.deletedCount == 1 {
                    routes.remove(at: routes.firstIndex(of: route)!)
                }
            } catch let error {
                print(error)
            }
        }.resume()
    }
    
    private func uploadRoute() {
        let routeRes = selectedRoute!.toRouteResponse()
        let jsonData = try? JSONEncoder().encode(routeRes)
        
        let url = URL(string: server + "/route")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            do {
                let route = try JSONDecoder().decode(RouteResponse.self, from: data)
                routes.append(route.toRoute())
            } catch let error {
                print(error)
            }
        }.resume()
    }
    
    private func searchForRoutes() {
        newRoutes.removeAll()
        guard startLoc != nil && endLoc != nil else { return }

        // find routes recursively
        checkNextRoute(startLoc: nil, endLoc: nil, points: [], dist: 0, routes: routes.filter({ $0.type != .bus }))
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        for i in 0..<newRoutes.count {
            newRoutes[i].id = formatter.string(from: Date()) + " " + String(i + 1)
        }
        
        newRoutes.sort(by: { $0.dist < $1.dist })
        
        selectedRoute = newRoutes.first
        
    }
    private func checkNextRoute(startLoc: Location?, endLoc: Location?, points: [Coor3D], dist: Double, routes: [Route]) {
        if startLoc == self.startLoc && endLoc == self.endLoc {
            newRoutes.append(Route(id: "", startLoc: startLoc!, endLoc: endLoc!, points: points, dist: dist, type: RouteType.bus))
            return
        }
        
        if startLoc == nil { // to find the first route
            for i in 0..<routes.count {
                if routes[i].startLoc == self.startLoc {
                    print(routes[i].startLoc.nameEn, routes[i].endLoc.nameEn)
                    checkNextRoute(startLoc: routes[i].startLoc, endLoc: routes[i].endLoc, points: routes[i].points, dist: routes[i].dist, routes: routes)
                } else if routes[i].endLoc == self.startLoc {
                    print(routes[i].endLoc.nameEn, routes[i].startLoc.nameEn)
                    checkNextRoute(startLoc: routes[i].endLoc, endLoc: routes[i].startLoc, points: routes[i].points.reversed(), dist: routes[i].dist, routes: routes)
                }
            }
        } else {
            for i in 0..<routes.count {
                if routes[i].startLoc == endLoc {
                    if isOverlapped(points1: points, points2: routes[i].points) { continue }
                    print(routes[i].startLoc.nameEn, routes[i].endLoc.nameEn)
                    checkNextRoute(startLoc: startLoc, endLoc: routes[i].endLoc, points: points + routes[i].points, dist: dist + routes[i].dist, routes: routes)
                } else if routes[i].endLoc == endLoc {
                    if isOverlapped(points1: points, points2: routes[i].points) { continue }
                    print(routes[i].endLoc.nameEn, routes[i].startLoc.nameEn)
                    checkNextRoute(startLoc: startLoc, endLoc: routes[i].startLoc, points: points + routes[i].points.reversed(), dist: dist + routes[i].dist, routes: routes)
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
}

