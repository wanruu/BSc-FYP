import Foundation
import SwiftUI

enum Page {
    case traj
    case loc
    case bus
}


struct MainPage: View {
    @State var page: Page = .traj
    @State var showMenu: Bool = false
    @StateObject var locationGetter = LocationGetterModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                switch page {
                    case .traj: TrajPage(locationGetter: locationGetter)
                    case .loc: LocationPage(current: $locationGetter.current)
                    case .bus: BusPage()
                }
            }
            .navigationBarTitle(Text(pageTitle()), displayMode: .inline)
            .navigationBarItems(leading:
                Menu("Menu", content: {
                    Button(action: { page = .traj }) { Text("Trajectory") }
                    Button(action: { page = .loc }) { Text("Location") }
                    Button(action: { page = .bus }) { Text("Bus") }
                })
            )
        }
    }
    
    private func pageTitle() -> String {
        switch page {
            case .traj: return "Trajectory"
            case .loc: return "Location"
            case .bus: return "Bus"
        }
    }
}
