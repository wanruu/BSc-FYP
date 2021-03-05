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
            LoadImage()
            
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
                saveVersion(version!)
                saveLocations(locations)
                saveBuses(buses)
                saveRoutes(routesByBus + routesOnFoot)
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
            loadBusesRemotely(locations: locations)
        } else {
            let lastVersion = CDVersions[0]
            loadLocsLocally()
            if lastVersion.routes == version?.routes {
                loadRoutesLocally(locations: locations)
            } else {
                loadRoutesRemotely()
            }
            if lastVersion.buses == version?.buses {
                loadBusesLocally(locations: locations)
            } else {
                loadBusesRemotely(locations: locations)
            }
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
        locations = CDLocations.map({ $0.toLocation() })
        tasks[.locations] = true
        text = "Location data loaded."
    }
    
    private func loadBusesLocally(locations: [Location]) {
        text = "Loading bus data locally..."
        buses = CDBuses.map({ $0.toBus(locations: locations) })
        tasks[.buses] = true
        text = "Buses data loaded."
    }
    
    private func loadRoutesLocally(locations: [Location]) {
        text = "Loading route data locally..."
        routesByBus.removeAll()
        routesOnFoot.removeAll()
        for CDroute in CDRoutes {
            let route = CDroute.toRoute(locations: locations)
            switch route.type {
            case .byBus: routesByBus.append(route)
            case .onFoot: routesOnFoot.append(route)
            }
        }
        tasks[.routes] = true
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
                locations = locRes.map({ $0.toLocation() })
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
    private func loadBusesRemotely(locations: [Location]) {
        let url = URL(string: server + "/buses")!
        text = "Loading bus data remotely..."
        URLSession.shared.dataTask(with: url) { data, response, error in
            text = "Resolving bus data..."
            guard let data = data else { return }
            do {
                let busRes = try JSONDecoder().decode([BusResponse].self, from: data)
                buses = busRes.map({ $0.toBus(locations: locations )})
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
        text = "Loading route data remotely..."
        URLSession.shared.dataTask(with: url) { data, response, error in
            text = "Resolving route data..."
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
                text = "Route data resolved."
            } catch let error {
                print(error)
                text = "Failed to resolve route data."
            }
        }.resume()
    }
    
    // MARK: - core data
    private func saveVersion(_ version: Version) {
        if CDVersions.isEmpty {
            let newVersion = CDVersion(context: viewContext)
            newVersion.locations = version.locations
            newVersion.buses = version.buses
            newVersion.routes = version.routes
        } else {
            CDVersions[0].locations = version.locations
            CDVersions[0].buses = version.buses
            CDVersions[0].routes = version.routes
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
    
    private func saveLocations(_ locations: [Location]) {
        for loc in CDLocations {
            viewContext.delete(loc)
        }
        for location in locations {
            let newLoc = CDLocation(context: viewContext)
            newLoc.id = location.id
            newLoc.nameEn = location.nameEn
            newLoc.nameZh = location.nameZh
            newLoc.latitude = location.latitude
            newLoc.longitude = location.longitude
            newLoc.altitude = location.altitude
            newLoc.type = location.type.toInt()
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    
    private func saveBuses(_ buses: [Bus]) {
        for bus in CDBuses {
            viewContext.delete(bus)
        }
        for bus in buses {
            let newBus = CDBus(context: viewContext)
            newBus.id = bus.id
            newBus.line = bus.line
            newBus.nameEn = bus.nameEn
            newBus.nameZh = bus.nameZh
            newBus.serviceHour = bus.serviceHour.toString()
            newBus.serviceDay = bus.serviceDay.toInt()
            newBus.departTime = bus.departTime
            newBus.stops = bus.stops.map({ $0.id })
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }

    private func saveRoutes(_ routes: [Route]) {
        for route in routes {
            let newRoute = CDRoute(context: viewContext)
            newRoute.id = route.id
            newRoute.startLoc = route.startLoc.id
            newRoute.endLoc = route.endLoc.id
            newRoute.points = route.points.map({ CDCoor3D(point: $0) })
            newRoute.dist = route.dist
            newRoute.type = route.type.toInt()
        }
        do {
            try viewContext.save()
        } catch {
            let nsError = error as NSError
            fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
        }
    }
}


struct LoadImage: View {
    var body: some View {
        HStack {
            Text("C")
            
        }
    }
}
