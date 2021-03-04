import SwiftUI

enum PageType {
    case loadPage
    case locPage
    case busPage
    //case naviPage
    case savedPage
}

struct MainPage: View {
    @StateObject var locationModel = LocationModel()
    
    @State var locations: [Location] = []
    @State var buses: [Bus] = []
    @State var routesOnFoot: [Route] = []
    @State var routesByBus: [Route] = []
    
    @State var pageType: PageType = .loadPage
    
    var body: some View {
        if pageType == .loadPage {
            LoadPage(locations: $locations, buses: $buses, routesOnFoot: $routesOnFoot, routesByBus: $routesByBus, loadTasks: [Bool](repeating: false, count: 3), pageType: $pageType)
        } else {
            NavigationView {
                ZStack {
                    switch pageType {
                    case .locPage: LocPage(locations: locations, buses: buses, routesOnFoot: routesOnFoot, routesByBus: routesByBus, pageType: $pageType)
                    case .busPage: BusPage(locations: locations, buses: buses, routesByBus: routesByBus)
                    case .savedPage: Text("Saved page")
                    default: Text("This shouldn't be seen.")
                    }
                }
                .toolbar {
                    ToolbarItemGroup(placement: .bottomBar) {
                        Spacer()
                        ToolBarItem(imgName: "building.2", text: "Location", thisPageType: .locPage, pageType: $pageType)
                        Spacer()
                        ToolBarItem(imgName: "bus", text: "Bus", thisPageType: .busPage, pageType: $pageType)
                        //Spacer()
                        //ToolBarItem(imgName: "arrow.triangle.turn.up.right.diamond", text: "Navigation", thisPageType: .naviPage, pageType: $pageType)
                        Spacer()
                        ToolBarItem(imgName: "heart", text: "Saved", thisPageType: .savedPage, pageType: $pageType)
                        Spacer()
                    }
                }
            }
            .environmentObject(locationModel)
        }
    }
    
    struct ToolBarItem: View {
        var imgName: String
        var text: String
        var thisPageType: PageType
        @Binding var pageType: PageType
        
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
            .foregroundColor(thisPageType == pageType ? Color.accentColor : Color.secondary)
            .onTapGesture {
                pageType = thisPageType
            }
        }
    }
}

