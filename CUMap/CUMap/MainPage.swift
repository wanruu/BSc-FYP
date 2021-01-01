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
    @State var plans: [Plan] = []
    @State var planIndex: Int = 0
    @State var mode: TransMode = .bus
    
    // height of plan view
    @State var lastHeight: CGFloat = -UIScreen.main.bounds.height * 0.1
    @State var height: CGFloat = -UIScreen.main.bounds.height * 0.1
    
    var body: some View {
        ZStack {
            MapView(plans: $plans, planIndex: $planIndex, locationGetter: locationGetter, lastHeight: $lastHeight, height: $height)
            
            PlansView(locations: locations, plans: $plans, lastHeight: $lastHeight, height: $height)
            
            SearchView(locations: locations, routes: routes, plans: $plans, locationGetter: locationGetter, mode: $mode, lastHeight: $lastHeight, height: $height)
        }
    }
}
