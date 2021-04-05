import SwiftUI
import UIKit

struct LocPage: View {
    
    @EnvironmentObject var store: Store
    
    @Environment(\.colorScheme) var colorScheme
    @EnvironmentObject var locationModel: LocationModel
    
    
    var binding: Binding<AppState.LocPage>{
        $store.appState.locPage
    }
    
    // input data
    //    @State var locations: [Location] = []
    //    @State var buses: [Bus] = []
    //    @State var routesOnFoot: [Route] = []
    //    @State var routesByBus: [Route] = []
    
    @State var selectedLoc: Location? = nil
    
    @State var showLocList = false
    @State var showNavi = false
    @State var showBottomSheet = false
    @Binding var showToolBar: Bool
    
    
    @State var isLiked = false
    
    var body: some View {
        ZStack {
            LocMapView(selectedLoc: $selectedLoc, showBottomSheet: $showBottomSheet)
            if !showBottomSheet {
                naviButton
            }
            searchArea
            SheetView(showNavi: $showNavi, showBottomSheet: $showBottomSheet, selectedLoc: $selectedLoc, height: .small)
        }
        .navigationBarHidden(true)
        
        .onChange(of: showBottomSheet){ _ in
            showToolBar = !showBottomSheet
        }
        
    }
    
    var searchArea: some View {
        VStack {
            HStack {
                NavigationLink(destination: LocListView(placeholder: "Search for location", keyword: selectedLoc?.nameEn ?? "", showCurrent: false, selectedLoc: $selectedLoc, showing: $showLocList), isActive: $showLocList) {
                    Text(selectedLoc?.nameEn ?? "Search for location")
                        .foregroundColor(selectedLoc == nil ? .secondary : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                selectedLoc == nil ? nil : Image(systemName: "xmark").contentShape(Rectangle())
                    .onTapGesture {
                        selectedLoc = nil
                        showBottomSheet = false
                    }
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
                NavigationLink(destination: NaviPage(showing: $showNavi), isActive: $showNavi) {
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
}



struct LocPage_Previews: PreviewProvider {
    static var previews: some View {
        LocPage(showToolBar: .constant(true))
            .environmentObject(LocationModel())
    }
}
