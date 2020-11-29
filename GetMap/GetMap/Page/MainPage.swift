//
//  MainPage.swift
//  GetMap
//
//  Created by wanruuu on 29/11/2020.
//

import Foundation
import SwiftUI

struct MainPage: View {
    @Binding var trajectories: [[Coor3D]]
    @Binding var locations: [Location]
    
    @ObservedObject var locationGetter = LocationGetterModel()
    
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: MapPage(trajectories: $trajectories, locations: $locations, locationGetter: locationGetter)) {
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
