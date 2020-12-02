/* MARK: Main Page, navigation to Map Page & Location Page */

import Foundation
import SwiftUI

struct MainPage: View {
    @Binding var locations: [Location]
    @Binding var trajectories: [[Coor3D]]
    @Binding var lineSegments: [LineSeg]
    @Binding var representatives: [[Coor3D]]
    @Binding var p: [Location]
    
    @ObservedObject var locationGetter = LocationGetterModel()
    
    var body: some View {
        NavigationView {
            ScrollView (.horizontal, showsIndicators: false) {
                HStack (spacing: 10) {
                    NavigationLink(destination: MapPage(locations: $locations, trajectories: $trajectories, lineSegments: $lineSegments, representatives: $representatives, p: $p, locationGetter: locationGetter)) {
                        ZStack {
                            Image("map")
                                .resizable()
                                .frame(width: 250, height: 250)
                                .cornerRadius(20)
                            
                            VStack(alignment: .leading) {
                                Text("Map")
                                    .foregroundColor(Color.white) .shadow(color: Color.black, radius: 3, x: 3, y: 3)
                                    .font(.system(size: 60, weight: .bold, design: .rounded))
                                 
                            }.offset(x: -30, y: 80)
                            
                        }.frame(alignment: .center) .padding(.leading, 30)
                    }
                
                    NavigationLink(destination: LocationPage(locations: $locations)) {
                        ZStack {
                            Image("building")
                                .resizable()
                                .frame(width: 250, height: 250)
                                .cornerRadius(20)
                            
                            VStack(alignment: .leading) {
                                Text("Building")
                                    .foregroundColor(Color.white).shadow(color: Color.black, radius: 3, x: 3, y: 3)
                                    .font(.system(size: 55, weight: .bold, design: .rounded))
                                   
                            }
                            .offset(x: -10, y: 80)
                        }
                        .frame(alignment: .center).padding(.trailing, 30)
                        .navigationTitle("Home")

                    }
                }
            }
        }
    }
}
