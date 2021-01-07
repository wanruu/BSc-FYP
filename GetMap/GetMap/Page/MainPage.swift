import Foundation
import SwiftUI

struct MainPage: View {
    var body: some View {
        NavigationView {
            if UIDevice.current.localizedModel == "iPad" {
                MainPagePad()
            } else if UIDevice.current.localizedModel == "iPhone" {
                MainPagePhone()
            }
        }
    }
    /*
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
 */
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
    // 1 = SCWidth * 0.001
    var body: some View {
        VStack(alignment: .leading) {
            Text("Trajectory").font(.title3).bold()
            HStack(spacing: 30) {
                NavigationLink(destination: CollectPage()) {
                    PageItem(image: "collect", title: "Collect")
                }
                NavigationLink(destination: ProcessPage()) {
                    PageItem(image: "map", title: "Process")
                }
            }
            Text("Location").font(.title3).bold().padding(.top)
            HStack(spacing: 30) {
                NavigationLink(destination: LocationPage()) {
                    PageItem(image: "building", title: "Location")
                }
            }
            Text("Bus").font(.title3).bold().padding(.top)
            HStack(spacing: 30) {
                NavigationLink(destination: BusPage()) {
                    PageItem(image: "building", title: "Bus")
                }
            }
            Text("Search").font(.title3).bold().padding(.top)
            /* HStack(spacing: 30) {
                NavigationLink(destination: SearchPage(locations: $locations, routes: $routes)) {
                    PageItem(image: "building", title: "Search")
                }
            }*/
        }
    }
}

struct MainPagePad: View {
    var body: some View {
        NavigationView {
            List {
                // NavigationLink(destination: MapPage(locations: $locations, trajectories: $trajectories)) { Text("Map") }
                // NavigationLink(destination: LocationPage(locations: $locations)) { Text("Location") }
            }
            .navigationTitle("Home")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
