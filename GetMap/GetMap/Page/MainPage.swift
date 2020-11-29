/* MARK: Main Page, navigation to Map Page & Location Page */

import Foundation
import SwiftUI

struct MainPage: View {
    @Binding var locations: [Location]
    @Binding var trajectories: [[Coor3D]]
    @Binding var representatives: [[Coor3D]]
    
    @ObservedObject var locationGetter = LocationGetterModel()
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: MapPage(locations: $locations, trajectories: $trajectories, representatives: $representatives, locationGetter: locationGetter)) {
                    Text("Map").bold().font(.system(size: 30))
                }
                NavigationLink(destination: LocationPage(locations: $locations)) {
                    Text("Location List").bold().font(.system(size: 30))
                }
            }
                .navigationTitle("Home")
                .navigationBarTitleDisplayMode(.inline)
        }
    }
}
