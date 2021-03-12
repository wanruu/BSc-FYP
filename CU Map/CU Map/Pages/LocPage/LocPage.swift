import SwiftUI

struct LocPage: View {
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var locationModel: LocationModel
    
    // input data
    @State var locations: [Location]
    @State var buses: [Bus]
    @State var routesOnFoot: [Route]
    @State var routesByBus: [Route]
    
    @State var selectedLoc: Location? = nil
    
    @State var showLocList = false
    @State var showNavi = false
    @State var showBottomSheet = false
    @Binding var showToolBar: Bool
    
    @Binding var pageType: PageType

    var body: some View {
        ZStack {
            LocMapView(locations: locations, selectedLoc: $selectedLoc)
            if !showBottomSheet {
                naviButton
            }
            searchArea
            sheet
        }
        .navigationBarHidden(true)
        .onChange(of: selectedLoc, perform: { value in
            if let _ = value {
                showBottomSheet = true
                showToolBar = false
            } else {
                showBottomSheet = false
                showToolBar = true
            }
        })
    }
    
    var searchArea: some View {
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
        }
    }
    
    var naviButton: some View {
        VStack {
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
    
    var sheet: some View {
        BottomSheetView(showing: $showBottomSheet) {
            if let loc = selectedLoc {
                VStack(alignment: .leading) {
                    Text(loc.nameEn).font(.headline)
                    Text(loc.type.toString()).font(.subheadline)
                    HStack {
                        NavigationLink(destination: NaviPage(locations: locations, buses: buses, routesOnFoot: routesOnFoot, routesByBus: routesByBus, startLoc: Location(id: UUID().uuidString, nameEn: "Your Location", nameZh: "你的位置", latitude: locationModel.current.latitude, longitude: locationModel.current.longitude, altitude: locationModel.current.altitude, type: .user), endLoc: loc, showing: $showNavi), isActive: $showNavi) {
                                Text("Directions")
                            }
                    }
                    Divider()
                }
                .padding(.horizontal)
            }
        }
    }
    
}
