import Foundation
import SwiftUI

struct MainPage: View {
    
    @State var page: String = "Bus"
    
    var body: some View {
        ZStack {
            if page == "Trajectory" {
                TrajPage()
            } else if page == "Location" {
                LocationPage()
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
                // safe area
                Color.white.frame(width: geometry.size.width, height: geometry.safeAreaInsets.bottom, alignment: .center)
                        
                // current page
                Button(action: {
                    if offset == -UIScreen.main.bounds.height {
                        offset = 0
                    } else {
                        offset = -UIScreen.main.bounds.height
                    }
                }) {
                    Text(page)
                        .foregroundColor(.black)
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .padding()
                        .frame(width: geometry.size.width, alignment: .center)
                }
                .frame(width: geometry.size.width, alignment: .center)
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


