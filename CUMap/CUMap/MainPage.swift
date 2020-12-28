/*
    MainPage.
    ---------------------
    |    Search View    |
    ---------------------
    |                   |
    |     Map View      |
    |                   |
    ---------------------
    |  Plans Text View  |
    ---------------------
 
 */

import Foundation
import SwiftUI

// MARK: - MapPage
struct MainPage: View {
    @State var locations: [Location]
    @State var routes: [Route]
    @ObservedObject var locationGetter: LocationGetterModel
    
    // search result
    @State var plans: [[Route]] = [
        [
            Route(
                id: "",
                startId: "5fc101b8590ae91c8514aa0e",
                endId: "5fc101e4590ae91c8514aa0f",
                points: [
                    Coor3D(latitude: 22.422267809368847, longitude: 114.20109505067131, altitude: 86.67837538011372),
                    Coor3D(latitude: 22.415161267808674, longitude: 114.20719342107641, altitude: 33.75990676879883)
                ],
                dist: 10,
                type: 0
            )
        ]
    ]
    @State var mode: TransMode = .bus
    
    var body: some View {
        ZStack {
            MapView(plans: plans, locationGetter: locationGetter)
            SearchView(locations: locations, routes: routes, plans: plans, locationGetter: locationGetter, mode: $mode)
            PlansTextView(locations: locations, plans: plans, mode: mode)
        }
    }
}
