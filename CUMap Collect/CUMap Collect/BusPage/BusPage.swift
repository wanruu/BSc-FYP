//  BusPage ->
//      BusListView ->
//          BusMapView
//      NewBusView ->
//          StopListView
//      NewRouteView ->
//          RouteMapView

import SwiftUI

struct BusPage: View {
    @State var locations: [Location] = []
    @State var buses: [Bus] = []
    @State var routes: [Route] = []
    
    @State var showNewBusView = false
    @State var showNewRouteView = false
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 20) {
                Spacer()
                NavigationLink(destination: NewBusView(locations: $locations, buses: $buses, showing: $showNewBusView), isActive: $showNewBusView) {
                    Image(systemName: "plus.circle").imageScale(.large).contentShape(Rectangle())
                }
                NavigationLink(destination: NewRouteView(locations: $locations, routes: $routes, showing: $showNewRouteView), isActive: $showNewRouteView) {
                    Image(systemName: "magnifyingglass").imageScale(.large).contentShape(Rectangle())
                }
            }.padding()
            
            Divider()
            
            BusListView(locations: $locations, buses: $buses, routes: $routes)
        }
        .navigationBarHidden(true)
        // .navigationBarTitle(Text(NSLocalizedString("School Bus", comment: "")), displayMode: .inline)
        
        .onAppear {
            loadLocationsBuses()
            loadRoutes()
        }
    }
    
    private func loadLocationsBuses() {
        let url = URL(string: server + "/locations")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let locRes = try JSONDecoder().decode([LocResponse].self, from: data)
                var locations: [Location] = []
                for loc in locRes {
                    locations.append(loc.toLocation())
                }
                self.locations = locations
                loadBuses()
            } catch let error {
                print(error)
            }
        }.resume()
    }
    private func loadBuses() {
        let url = URL(string: server + "/buses")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let busRes = try JSONDecoder().decode([BusResponse].self, from: data)
                var buses: [Bus] = []
                for bus in busRes {
                    buses.append(bus.toBus(locations: locations))
                }
                self.buses = buses
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
                let routeRes = try JSONDecoder().decode([RouteResponse].self, from: data)
                var routes: [Route] = []
                for route in routeRes {
                    routes.append(route.toRoute())
                }
                self.routes = routes
            } catch let error {
                print(error)
            }
        }.resume()
    }
}

struct BusPage_Previews: PreviewProvider {
    static var previews: some View {
        BusPage()
    }
}
