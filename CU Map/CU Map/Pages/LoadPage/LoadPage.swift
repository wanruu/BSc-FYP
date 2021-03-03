import SwiftUI

struct LoadPage: View {
    @Binding var locations: [Location]
    @Binding var buses: [Bus]
    @Binding var routesOnFoot: [Route]
    @Binding var routesByBus: [Route]
    
    @State var loadTasks = [Bool](repeating: false, count: 3)
    
    @Binding var pageType: PageType
    
    var body: some View {
        Text("Loading...")
            .onAppear {
                loadLocationsBuses()
                loadRoutes()
            }
            .onChange(of: loadTasks) { data in
                if data.filter({$0}).count == 3 {
                    pageType = .locPage
                }
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
                loadTasks[0] = true
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
                loadTasks[1] = true
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
                routesOnFoot.removeAll()
                routesByBus.removeAll()
                for route in routeRes {
                    switch route.type.toRouteType() {
                    case .onFoot: routesOnFoot.append(route.toRoute())
                    case .byBus: routesByBus.append(route.toRoute())
                    }
                }
                loadTasks[2] = true
            } catch let error {
                print(error)
            }
        }.resume()
    }
}
