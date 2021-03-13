import SwiftUI

enum Page {
    case loading
    case trajectory
    case location
    case bus
}

struct MainPage: View {
    @StateObject var locationModel = LocationModel()
    
    @State var locations: [Location] = []
    @State var buses: [Bus] = []
    @State var routesOnFoot: [Route] = []
    @State var routesByBus: [Route] = []
    
    @State var showToolBar: Bool = true
    @State var page: Page = .loading
    
    var body: some View {
        if page == .loading {
            LoadPage(locations: $locations, buses: $buses, routesOnFoot: $routesOnFoot, routesByBus: $routesByBus, page: $page)
        } else {
            NavigationView {
                ZStack {
                    switch page {
                    case .trajectory: TrajPage(locationModel: locationModel)
                    case .location: LocPage(locations: $locations, current: $locationModel.current, showToolBar: $showToolBar)
                    case .bus: BusPage()
                    default: Text("This shouldn't be seen.")
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        if showToolBar {
                            Spacer()
                            ToolBarItem(imgName: "point.fill.topleft.down.curvedto.point.fill.bottomright.up", text: "trajectory", thisPage: .trajectory, page: $page)
                            Spacer()
                            ToolBarItem(imgName: "building.2", text: "location", thisPage: .location, page: $page)
                            Spacer()
                            ToolBarItem(imgName: "bus", text: "school bus", thisPage: .bus, page: $page)
                            Spacer()
                        }
                    }
                }
            }
        }
    }
    
    
    struct ToolBarItem: View {
        var imgName: String
        var text: String
        var thisPage: Page
        @Binding var page: Page
        
        var body: some View {
            VStack {
                Image(systemName: imgName)
                    .imageScale(.large)
                Text(NSLocalizedString(text, comment: text + "page"))
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
            .padding(.top)
            .frame(width: UIScreen.main.bounds.width * 0.25)
            .foregroundColor(thisPage == page ? Color.accentColor : Color.secondary)
            .contentShape(Rectangle())
            .onTapGesture {
                page = thisPage
            }
        }
    }
}
