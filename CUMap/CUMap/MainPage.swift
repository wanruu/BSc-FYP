/*
 - MapPage
    - MapView
    - Image
    - ResultView
    - SearchView
 */

/*
    MainPage.
    ---------------------
    [ From              ]
    [ To                ]
    ---------------------
    |                   |
    |        Map        |
    |                   |
    ---------------------
    |      Result       |
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
    @State var plans: [[Route]] = []
    
    @State var startId = ""
    @State var endId = ""
    
    var body: some View {
        ZStack {
            MapView(plans: plans, locationGetter: locationGetter)
            SearchView(locations: locations, routes: routes, plans: plans, locationGetter: locationGetter)
        }
    }
}
