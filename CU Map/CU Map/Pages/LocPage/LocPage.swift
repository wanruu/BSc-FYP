import SwiftUI

struct LocPage: View {
    @Environment(\.colorScheme) var colorScheme
    
    // input data
    @State var locations: [Location]
    @State var buses: [Bus]
    @State var routesOnFoot: [Route]
    @State var routesByBus: [Route]
    
    @State var selectedLoc: Location? = nil
    
    @State var showLocList = false
    @State var showNavi = false
    
    @Binding var pageType: PageType

    var body: some View {
        ZStack {
            LocMapView(locations: locations, selectedLoc: $selectedLoc)
                .ignoresSafeArea(.all)
            VStack {
                HStack {
                    NavigationLink(destination: LocListView(placeholder: "Search for location", keyword: selectedLoc?.nameEn ?? "", locations: locations, showCurrent: false, selectedLoc: $selectedLoc, showing: $showLocList), isActive: $showLocList) {
                        Text(selectedLoc?.nameEn ?? "Search for location")
                            .foregroundColor(selectedLoc == nil ? .secondary : .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    selectedLoc == nil ? nil : Image(systemName: "xmark").contentShape(Rectangle()).onTapGesture { selectedLoc = nil }
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.secondary, lineWidth: 1))
                .background(colorScheme == .light ? Color.white : Color.black)
                .cornerRadius(16)
                .clipped()
                .shadow(radius: 5)
                .padding()
                
                Spacer()
                
                HStack {
                    Spacer()
                    NavigationLink(destination: NaviPage(locations: locations, buses: buses, routesOnFoot: routesOnFoot, routesByBus: routesByBus, showing: $showNavi), isActive: $showNavi) {
                        Image(systemName: "arrow.triangle.swap")
                            .resizable()
                            .frame(width: UIScreen.main.bounds.width * 0.05, height: UIScreen.main.bounds.width * 0.05, alignment: .center)
                            .scaledToFit()
                            .rotationEffect(Angle(degrees: 90))
                            .padding(6)
                    }
                    .buttonStyle(NaviButtonStyle(fgColor: .white, bgColor: .accentColor))
                    .padding()
                    .padding()
                }
                
            }
        }
        .navigationBarHidden(true)
    }
}
