import SwiftUI
import MapKit

struct BusView: View {
    @State var locations: [Location] = []
    @State var buses: [Bus] = []
    @State var routes: [Route] = []
    
    @State var showNewBusView: Bool = false

    var body: some View {
        NavigationView {
            List {
                ForEach(buses) { bus in
                    NavigationLink(destination: BusMapView(bus: bus, routes: $routes).ignoresSafeArea(.all)) {
                        BusListItem(bus: bus)
                    }.disabled(bus.stops.isEmpty)
                }.onDelete { indexSet in
                    deleteBus(index: indexSet.first!)
                }
            }
            .listStyle(PlainListStyle())
            .navigationBarTitle(Text(NSLocalizedString("School Bus", comment: "")))
            .navigationBarItems(trailing:
                NavigationLink(destination: NewBusView(locations: $locations, buses: $buses, showing: $showNewBusView), isActive: $showNewBusView) {
                    Image(systemName: "plus.circle").imageScale(.large).contentShape(Rectangle())
                }
            )
        }
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


struct BusListItem: View {
    @State var bus: Bus
    var body: some View {
        HStack {
            VStack {
                Text(bus.id).font(.system(size: 45, weight: .semibold, design: .rounded))
                Text(bus.nameEn).font(.system(size: 15, design: .rounded))
            }.lineLimit(1).minimumScaleFactor(0.2).frame(width: UIScreen.main.bounds.width * 0.2)
            VStack(alignment: .leading) {
                Text(bus.serviceHour.toString())
                switch bus.serviceDay {
                case .holiday: Text(NSLocalizedString("Sun & Public holidays", comment: ""))
                case .teachingDay: Text(NSLocalizedString("Teaching days only", comment: ""))
                case .ordinaryDay:
                    VStack(alignment: .leading) {
                        Text(NSLocalizedString("Mon - Sat", comment: ""))
                        Text("* " + NSLocalizedString("Service suspended on Public Holidays", comment: "")).font(.footnote).italic().foregroundColor(.gray)
                    }
                }
                Text(NSLocalizedString("Departs hourly at (mins)", comment: "") + ": " + bus.departTime.description).lineLimit(2)
            }
        }
    }
}




struct BusView_Previews: PreviewProvider {
    static var previews: some View {
        BusView()
    }
}
