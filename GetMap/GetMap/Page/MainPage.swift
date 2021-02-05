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
                showMenu ? PageMenu(showing: $showMenu ,page: $page) : nil
                
            }
            .navigationBarTitle(Text(pageTitle()), displayMode: .inline)
            .navigationBarItems(trailing:
                Button(action: {
                    showMenu.toggle()
                }) {
                    Text("Menu")
                }
                /*Menu("Menu") {
                    Button(action: { page = .traj }) { Text("Trajectory") }
                    Button(action: { page = .loc }) { Text("Location") }
                    Button(action: { page = .bus }) { Text("Bus") }
                }*/
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

struct PageMenu: View {
    @Binding var showing: Bool
    @Binding var page: Page
    var body: some View {
        ZStack {
            Color.gray.opacity(0.2)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea(.all)
                .onTapGesture {
                    showing.toggle()
                }

            VStack(spacing: 0) {
                Button(action: {
                    page = .traj
                    showing.toggle()
                }) {
                    Text("Trajectory").padding().frame(maxWidth: .infinity)
                }.buttonStyle(MyButtonStyle3(bgColor: Color.gray.opacity(0.5)))
                
                Divider()
                
                Button(action: {
                    page = .loc
                    showing.toggle()
                }) {
                    Text("Location").padding().frame(maxWidth: .infinity)
                }.buttonStyle(MyButtonStyle3(bgColor: Color.gray.opacity(0.5)))
                
                Divider()
                
                Button(action: {
                    page = .bus
                    showing.toggle()
                }) {
                    Text("Bus").padding().frame(maxWidth: .infinity)
                }.buttonStyle(MyButtonStyle3(bgColor: Color.gray.opacity(0.5)))
            }
            .background(Color.white)
            .cornerRadius(10)
            .clipped()
            .shadow(radius: 10)
            .padding(.horizontal)
        }
    }
}
