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
    @State var startId = ""
    @State var endId = ""
    @State var plans: [[Route]] = []
    @State var mode: TransMode = .bus
    
    // height of pland text view
    @State var lastHeight = smallH
    @State var height = smallH
    
    var body: some View {
        ZStack {
            MapView(plans: plans, locationGetter: locationGetter, lastHeight: $lastHeight, height: $height)
            
            SearchView(locations: locations, routes: routes, plans: $plans, locationGetter: locationGetter, mode: $mode, startId: $startId, endId: $endId)

            if startId != "" && endId != "" {
                PlansTextView(locations: locations, plans: plans, lastHeight: $lastHeight, height: $height)
            }
        }
    }
}
