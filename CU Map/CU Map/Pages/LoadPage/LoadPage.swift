import SwiftUI
import CoreData

struct LoadPage: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: []) private var CDVersions: FetchedResults<CDVersion>
    @FetchRequest(sortDescriptors: []) private var CDLocations: FetchedResults<CDLocation>
    @FetchRequest(sortDescriptors: []) private var CDBuses: FetchedResults<CDBus>
    @FetchRequest(sortDescriptors: []) private var CDRoutes: FetchedResults<CDRoute>
    
    @State var version: Version? = nil
    @Binding var locations: [Location]
    @Binding var buses: [Bus]
    @Binding var routesOnFoot: [Route]
    @Binding var routesByBus: [Route]
    
    @State var text = "Loading data..."
    @State var tasks: [Task: Bool] = [.versions: false, .locations: false, .routes: false, .buses: false]
    
    @Binding var pageType: PageType
    
    var body: some View {
        VStack {
            ProgressView(value: Double(tasks.filter({$0.value}).count) / Double(tasks.count)) {
                Text(text)
                    .italic()
                    .font(.system(size: 15, weight: .regular, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
            }
            .progressViewStyle(LoadingProgressViewStyle())
            .padding()
        }
        .onAppear {
            loadData()
        }
        .onChange(of: tasks) { data in
            if data.filter({ $0.value }).count == data.count {
                pageType = .locPage
            }
        }
    }
    
    enum Task {
        case versions
        case locations
        case routes
        case buses
    }
    
    private func loadData() {
        getVersion()
        // if locations changed, routes and buses must be loaded
        if CDVersions.isEmpty || CDVersions[0].locations != version?.locations {
            loadLocsRemotely()
            loadRoutesRemotely()
            loadBusesRemotely() // must succeed loadLocsRemotely()
        } else {
            let lastVersion = CDVersions[0]
            loadLocsLocally()
            if lastVersion.routes == version?.routes ?? "" {
                loadRoutesLocally()
            } else {
                loadRoutesRemotely()
            }
            if lastVersion.buses == version?.buses ?? "" {
                loadBusesLocally()
            } else {
                loadBusesRemotely()
            } // must succeed loadLocs()
        }
    }
    
    private func getVersion() {
        let sema = DispatchSemaphore(value: 0)
        let url = URL(string: server + "/versions")!
        text = "Loading version infomation remotely..."
        URLSession.shared.dataTask(with: url) { data, response, error in
            text = "Resolving version data..."
            guard let data = data else { return }
            do {
                version = try JSONDecoder().decode(Version.self, from: data)
                text = "Version data resolved."
                tasks[.versions] = true
                sema.signal()
            } catch let error {
                print(error)
                text = "Failed to resolve version data."
                sema.signal()
            }
        }.resume()
        sema.wait()
    }
    
    private func loadLocsLocally() {
        text = "Loading location data locally..."
        locations.removeAll()
        for loc in CDLocations {
            locations.append(Location(id: loc.id, nameEn: loc.nameEn, nameZh: loc.nameZh, latitude: loc.latitude, longitude: loc.longitude, altitude: loc.altitude, type: loc.type.toLocationType()))
        }
        text = "Location data loaded."
    }
    
    private func loadBusesLocally() {
        text = "Loading bus data locally..."
        buses.removeAll()
        for bus in CDBuses {
            buses.append(bus.toBus(locations: locations))
        }
        text = "Buses data loaded."
    }
    
    private func loadRoutesLocally() {
        text = "Loading route data locally..."
        routesByBus.removeAll()
        routesOnFoot.removeAll()
        for CDroute in CDRoutes {
            let route = CDroute.toRoute()
            switch route.type {
            case .byBus: routesByBus.append(route)
            case .onFoot: routesOnFoot.append(route)
            }
        }
        text = "Route data loaded."
    }
    
    // sync
    private func loadLocsRemotely() {
        let sema = DispatchSemaphore(value: 0)
        let url = URL(string: server + "/locations")!
        text = "Loading location data remotely..."
        URLSession.shared.dataTask(with: url) { data, response, error in
            text = "Resolving location data..."
            guard let data = data else { return }
            do {
                let locRes = try JSONDecoder().decode([LocResponse].self, from: data)
                locations.removeAll()
                for loc in locRes {
                    locations.append(loc.toLocation())
                }
                tasks[.locations] = true
                text = "Location data resolved."
                sema.signal()
            } catch let error {
                print(error)
                text = "Failed to resolve location data."
                sema.signal()
            }
        }.resume()
        sema.wait()
    }
    
    // async
    private func loadBusesRemotely() {
        let url = URL(string: server + "/buses")!
        text = "Loading bus data remotely..."
        URLSession.shared.dataTask(with: url) { data, response, error in
            text = "Resolving bus data..."
            guard let data = data else { return }
            do {
                let busRes = try JSONDecoder().decode([BusResponse].self, from: data)
                buses.removeAll()
                for bus in busRes {
                    buses.append(bus.toBus(locations: locations))
                }
                tasks[.buses] = true
                text = "Bus data resolved."
            } catch let error {
                print(error)
                text = "Failed to resolve bus data."
            }
        }.resume()
    }
    
    // async
    private func loadRoutesRemotely() {
        let url = URL(string: server + "/routes")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            text = "Loading route data remotely..."
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
                tasks[.routes] = true
            } catch let error {
                print(error)
            }
        }.resume()
    }
    
    private func addVersion(version: Version) {
        let newVersion = CDVersion(context: viewContext)
        newVersion.locations = version.locations
        newVersion.buses = version.buses
        newVersion.routes = version.routes
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}
