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
                
                MenuView(page: $page, showMenu: $showMenu)
                    .offset(x: showMenu ? 0 : -UIScreen.main.bounds.width * 0.4)
                    .animation(.easeIn)
            }
            .navigationBarTitle(Text(pageTitle()), displayMode: .inline)
            .navigationBarItems(leading: Button(action: {
                showMenu.toggle()
            }) {
                Image(systemName: "list.bullet").imageScale(.large)
            })
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

struct MenuView: View {
    @Binding var page: Page
    @Binding var showMenu: Bool
    
    var body: some View {
        GeometryReader { geo in
            VStack(alignment: .leading, spacing: 0) {
                Divider()
                
                Button(action: {
                    page = .traj
                    showMenu.toggle()
                }) {
                    Text("Trajectory").frame(width: geo.size.width * 0.4)
                }.buttonStyle(MyButtonStyle3(bgColor: Color.gray.opacity(0.5)))
                
                Divider()
                
                Button(action: {
                    page = .loc
                    showMenu.toggle()
                }) {
                    Text("Location").frame(width: geo.size.width * 0.4)
                }.buttonStyle(MyButtonStyle3(bgColor: Color.gray.opacity(0.5)))
                
                Divider()
                
                Button(action: {
                    page = .bus
                    showMenu.toggle()
                }) {
                    Text("Bus").frame(width: geo.size.width * 0.4)
                }.buttonStyle(MyButtonStyle3(bgColor: Color.gray.opacity(0.5)))
                
                Divider()
            }
            .frame(maxWidth: geo.size.width * 0.4, maxHeight: .infinity, alignment: .top)
            .background(Color.white)
            .clipped()
            .shadow(radius: showMenu ? 10 : 0)
            .ignoresSafeArea(.container, edges: .bottom)
        }
    }
}
