import Foundation
import SwiftUI

struct MainPage: View {
    @State var page: String = "Bus"
    @StateObject var locationGetter = LocationGetterModel()
    var body: some View {
        ZStack {
            if page == "Trajectory" {
                TrajPage(locationGetter: locationGetter)
            } else if page == "Location" {
                LocationPage(current: $locationGetter.current)
            } else if page == "Bus" {
                BusPage()
            }
            Navi(page: $page)
        }
    }
}

struct Navi: View {

    @Binding var page: String
    
    // offset of dropdown page options
    @State var offset: CGFloat = -UIScreen.main.bounds.height
    
    var body: some View {
        GeometryReader { geometry in
            VStack (spacing: 0) {
                // current page
                Button(action: {
                    offset = offset == -UIScreen.main.bounds.height ? 0 : -UIScreen.main.bounds.height
                }) {
                    Text(page)
                        .foregroundColor(.black)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .padding()
                        .frame(width: geometry.size.width, alignment: .center)
                }
                .frame(width: geometry.size.width, alignment: .center)
                .padding(.top, geometry.size.height * 0.05)
                .background(Color.white)
                Divider().background(Color.white)
                
                // dropdown option
                VStack (spacing: 0) {
                    // option 1: traj
                    Button(action: {
                        page = "Trajectory"
                        offset = -UIScreen.main.bounds.height
                    }) {
                        Text("Trajectory")
                            .foregroundColor(.black)
                            .font(.system(size: 18, design: .rounded))
                            .frame(width: geometry.size.width, alignment: .center)
                    }
                    .background(Color.white)
                    .buttonStyle(MyButtonStyle3(bgColor: CUPurple.opacity(0.5)))
                    Divider()
                    // option 2: location
                    Button(action: {
                        page = "Location"
                        offset = -UIScreen.main.bounds.height
                    }) {
                        Text("Location")
                            .foregroundColor(.black)
                            .font(.system(size: 18, design: .rounded))
                            .frame(width: geometry.size.width, alignment: .center)
                    }
                    .background(Color.white)
                    .buttonStyle(MyButtonStyle3(bgColor: CUPurple.opacity(0.5)))
                    Divider()
                    // option 3: bus
                    Button(action: {
                        page = "Bus"
                        offset = -UIScreen.main.bounds.height
                    }) {
                        Text("Bus")
                            .foregroundColor(.black)
                            .font(.system(size: 18, design: .rounded))
                            .frame(width: geometry.size.width, alignment: .center)
                    }
                    .background(Color.white)
                    .buttonStyle(MyButtonStyle3(bgColor: CUPurple.opacity(0.5)))
                    Divider()
                }
                .background(Color.white)
                .zIndex(-10)
                .frame(width: geometry.size.width, alignment: .center)
                .offset(y: offset)
                .animation(Animation.easeInOut)
            }
            
        }
        .edgesIgnoringSafeArea(.top)
    }
}


