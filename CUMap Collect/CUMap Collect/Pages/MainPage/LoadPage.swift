import SwiftUI
import CoreData

struct LoadPage: View {
    @Binding var locations: [Location]
    @Binding var buses: [Bus]
    @Binding var routesOnFoot: [Route]
    @Binding var routesByBus: [Route]
    
    @State var text = "Start loading data..."
    @State var tasks: [Task: Bool] = [.locations: false, .routes: false, .buses: false]
    
    @Binding var page: Page

    var body: some View {
        VStack {
            LoadImage()
            VStack(alignment: .leading, spacing: 10){
                ProgressView(value: Double(tasks.filter({$0.value}).count) / Double(tasks.count))
                    .progressViewStyle(LoadingProgressViewStyle())
                    .animation(Animation.linear(duration: 1), value: tasks)
                Text(text)
                    .font(.footnote)
                    .italic()
                    .foregroundColor(.secondary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
            }
            .offset(y: UIScreen.main.bounds.height * 0.3)
        }
        .onAppear {
            loadData()
        }
        .navigationBarHidden(true)
    }
    
    enum Task {
        case locations
        case routes
        case buses
    }
    
    private func loadData() {
        let queue = DispatchQueue(label: "loadHandler")
        let group = DispatchGroup()
        queue.async(group: group) {
            loadLocsRemotely()
            loadRoutesRemotely()
            loadBusesRemotely(locations: locations)
            Thread.sleep(forTimeInterval: TimeInterval(1))
        }
        group.notify(queue: DispatchQueue.main) {
            text = "Everything is prepared."
            page = .location
        }
    }

    // sync
    private func loadLocsRemotely() {
        let sema = DispatchSemaphore(value: 0)
        let url = URL(string: server + "/locations")!
        text = "Loading location data remotely..."
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let locRes = try JSONDecoder().decode([LocResponse].self, from: data)
                locations = locRes.map({ $0.toLocation() })
                tasks[.locations] = true
            } catch let error {
                print(error)
            }
            sema.signal()
        }.resume()
        sema.wait()
    }
    
    // sync
    private func loadBusesRemotely(locations: [Location]) {
        let sema = DispatchSemaphore(value: 0)
        let url = URL(string: server + "/buses")!
        text = "Loading bus data remotely..."
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let busRes = try JSONDecoder().decode([BusResponse].self, from: data)
                buses = busRes.map({ $0.toBus(locations: locations )})
                tasks[.buses] = true
            } catch let error {
                print(error)
            }
            sema.signal()
        }.resume()
        sema.wait()
    }
    
    // sync
    private func loadRoutesRemotely() {
        let sema = DispatchSemaphore(value: 0)
        let url = URL(string: server + "/routes")!
        text = "Loading route data remotely..."
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
                tasks[.routes] = true
            } catch let error {
                print(error)
            }
            sema.signal()
        }.resume()
        sema.wait()
    }
}


struct LoadImage: View {
    @State var opacity = 0.5
    @State var scale: CGFloat = 1.5

    var body: some View {
        HStack {
            Text("CU Map Collect")
                .opacity(opacity)
                .scaleEffect(scale)
        }
        .font(.system(size: 50, weight: .bold, design: .rounded))
        .animation(Animation.easeIn(duration: 1), value: scale)
        .animation(Animation.easeIn(duration: 1), value: opacity)
        .onAppear {
            scale = 1.0
            opacity = 1
        }
    }
}
