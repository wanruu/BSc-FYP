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
        VStack(alignment: .leading, spacing: 30) {
            HStack(spacing: 30) {
                NavigationLink(destination: TrajPage()) {
                    PageItem(image: "collect", title: "Trajectory")
                }
                NavigationLink(destination: ProcessPage()) {
                    PageItem(image: "map", title: "Process Test")
                }
            }
            
            
            NavigationLink(destination: LocationPage()) {
                PageItem(image: "building", title: "Location")
            }
            

            NavigationLink(destination: BusPage()) {
                PageItem(image: "building", title: "Bus")
            }
            
            
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
