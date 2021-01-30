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
    // data used to do route planning
    @State var locations: [Location]
    @State var routes: [Route]
    @State var buses: [Bus]
    
    @ObservedObject var locationGetter: LocationGetterModel
    
    // search result
    @State var plans: [Plan] = []
    @State var planIndex: Int = 0
    @State var mode: TransMode = .bus
    
    // height of plan view
    @State var lastHeight: CGFloat = -UIScreen.main.bounds.height * 0.1
    @State var height: CGFloat = -UIScreen.main.bounds.height * 0.1
    
    var body: some View {
        ZStack {
            MapView(plans: $plans, planIndex: $planIndex, locationGetter: locationGetter, lastHeight: $lastHeight, height: $height)
            
            PlansView(plans: $plans, planIndex: $planIndex, lastHeight: $lastHeight, height: $height)
            
            SearchView(locationGetter: locationGetter, locations: locations, routes: routes, buses: buses, plans: $plans, planIndex: $planIndex, mode: $mode, lastHeight: $lastHeight, height: $height)
        }
    }
}
