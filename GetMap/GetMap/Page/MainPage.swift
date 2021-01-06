// MARK: Main Page, navigation to Map Page & Location Page

import Foundation
import SwiftUI

struct MainPage: View {
    // data loaded from server
    @State var locations: [Location] = []
    @State var trajectories: [Trajectory] = []
    @State var routes: [Route] = []
    
    @State var mapSys: [Route] = []
    
    @State var loadTasks = [Bool](repeating: false, count: 3)
    @State var showAlert = false
    
    var body: some View {
        ZStack {
            loadTasks.filter{$0 == true}.count == loadTasks.count ?
                ZStack {
                    UIDevice.current.localizedModel == "iPad" ?
                        MainPagePad(locations: $locations, trajectories: $trajectories, mapSys: $mapSys) : nil
                    UIDevice.current.localizedModel == "iPhone" ?
                        MainPagePhone(locations: $locations, trajectories: $trajectories, routes: $routes, mapSys: $mapSys) : nil
                } : nil
            loadTasks.filter{$0 == true}.count == loadTasks.count ? nil : LoadPage(tasks: $loadTasks)
        }
        .alert(isPresented: $showAlert) {
            Alert(
                title: Text("Error"),
                message: Text("Can not connect to server."),
                dismissButton: Alert.Button.default(Text("Try again")) {
                    load(tasks: loadTasks)
                }
            )
        }
        .onAppear {
            load(tasks: loadTasks)
       }
    }
    // MARK: - Load data from Server
    private func load(tasks: [Bool]) {
        for i in 0..<tasks.count {
            if(!tasks[i]) {
                switch i {
                    case 0: loadLocations()
                    case 1: loadTrajs()
                    case 2: loadRoutes()
                    default: return
                }
            }
        }
    }
    private func loadLocations() { // load task #0
        let url = URL(string: server + "/locations")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if(error != nil) {
                showAlert = true
            }
            guard let data = data else { return }
            do {
                locations = try JSONDecoder().decode([Location].self, from: data)
                loadTasks[0] = true
            } catch let error {
                showAlert = true
                print(error)
            }
        }.resume()
    }
    private func loadTrajs() { // load task #1
        let url = URL(string: server + "/trajectories")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if(error != nil) {
                showAlert = true
            }
            guard let data = data else { return }
            do {
                let res = try JSONDecoder().decode([Trajectory].self, from: data)
                trajectories =  res
                loadTasks[1] = true
            } catch let error {
                showAlert = true
                print(error)
            }
        }.resume()
    }
    private func loadRoutes() { // load task #2
        let url = URL(string: server + "/routes")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if(error != nil) {
                showAlert = true
            }
            guard let data = data else { return }
            do {
                let res = try JSONDecoder().decode([Route].self, from: data)
                routes = res
                loadTasks[2] = true
            } catch let error {
                showAlert = true
                print(error)
            }
        }.resume()
    }
}

struct PageItem: View {
    @State var image: String
    @State var title: String
    var body: some View {
        ZStack {
            Image(image)
                .resizable()
                .frame(width: SCWidth * 0.25, height: SCWidth * 0.25)
                .cornerRadius(SCWidth * 0.05)
            Text(title)
                .foregroundColor(Color.white)
                .shadow(color: Color.black, radius: SCWidth * 0.003, x: SCWidth * 0.003, y: SCWidth * 0.003)
                .font(.system(size: SCWidth * 0.055, weight: .bold, design: .rounded))
                .offset(y: SCWidth * 0.06)
        }
    }
}

struct MainPagePhone: View {
    @Binding var locations: [Location]
    @Binding var trajectories: [Trajectory]
    @Binding var routes: [Route]
    @Binding var mapSys: [Route]
    
    // 1 = SCWidth * 0.001
    var body: some View {
        NavigationView {
            VStack(alignment: .leading) {
                Text("Collect").font(.title3).bold()
                HStack {
                    NavigationLink(destination: CollectPage()) {
                        PageItem(image: "collect", title: "Collect")
                    }
                }
                Text("Process").font(.title3).bold().padding(.top)
                HStack(spacing: 30) {
                    NavigationLink(destination: MapPage(locations: $locations, trajectories: $trajectories, mapSys: $mapSys)) {
                        PageItem(image: "map", title: "Map")
                    }
                    NavigationLink(destination: LocationPage(locations: $locations)) {
                        PageItem(image: "building", title: "Location")
                    }
                    NavigationLink(destination: BusPage()) {
                        PageItem(image: "building", title: "Bus")
                    }
                }
                Text("Verify").font(.title3).bold().padding(.top)
                /* HStack(spacing: 30) {
                    NavigationLink(destination: SearchPage(locations: $locations, routes: $routes)) {
                        PageItem(image: "building", title: "Search")
                    }
                }*/
            }
        }
    }
}

struct MainPagePad: View {
    @Binding var locations: [Location]
    @Binding var trajectories: [Trajectory]
    @Binding var mapSys: [Route]
    
    var body: some View {
        NavigationView {
            List {
                // NavigationLink(destination: MapPage(locations: $locations, trajectories: $trajectories, mapSys: $mapSys)) { Text("Map") }
                // NavigationLink(destination: LocationPage(locations: $locations)) { Text("Location") }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
