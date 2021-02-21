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
    // data from server
    @State var locations: [Location]
    @State var routes: [Route]
    @State var buses: [Bus]
    
    // current location
    @ObservedObject var locationGetter: LocationGetterModel
    
    // selected start/end loc
    @State var startLoc: Location? = nil
    @State var endLoc: Location? = nil
    
    // search result
    @State var busPlans: [BusPlan] = []
    @State var walkPlans: [Plan] = []
    @State var chosenPlan: Plan? = nil
    @State var mode: TransMode = .bus
    
    // height of plan view
    @State var lastHeight: CGFloat = -UIScreen.main.bounds.height * 0.1
    @State var height: CGFloat = -UIScreen.main.bounds.height * 0.1
    
    var body: some View {
        ZStack {
            // MapView(chosenPlan: $chosenPlan, locationGetter: locationGetter, lastHeight: $lastHeight, height: $height)
            MapView(startLoc: $startLoc, endLoc: $endLoc, busPlans: $busPlans, walkPlans: $walkPlans, chosenPlan: $chosenPlan, mode: $mode)
            
            PlansView(buses: buses, busPlans: $busPlans, walkPlans: $walkPlans, chosenPlan: $chosenPlan, mode: $mode, lastHeight: $lastHeight, height: $height)
            
            SearchView(locationGetter: locationGetter, locations: locations, routes: routes, buses: buses, startLoc: $startLoc, endLoc: $endLoc, busPlans: $busPlans, walkPlans: $walkPlans, chosenPlan: $chosenPlan, mode: $mode, lastHeight: $lastHeight, height: $height)
        }
    }
}
