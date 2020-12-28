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
    @State var height = smallH
    
    var body: some View {
        ZStack {
            MapView(plans: plans, locationGetter: locationGetter, height: $height)
            withAnimation() {
                height < mediumH ? SearchView(locations: locations, routes: routes, plans: plans, locationGetter: locationGetter, mode: $mode, startId: $startId, endId: $endId) : nil
            }
            if startId != "" && endId != "" {
                PlansTextView(locations: locations, plans: plans, height: $height)
            }
        }
    }
}
