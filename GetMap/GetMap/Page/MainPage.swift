/* MARK: Main Page, navigation to Map Page & Location Page */

import Foundation
import SwiftUI

struct MainPage: View {
    @Binding var locations: [Location]
    @Binding var trajectories: [[Coor3D]]
    @Binding var lineSegments: [LineSeg]
    @Binding var representatives: [[Coor3D]]
    @Binding var p: [[Coor3D]]
    @Binding var mapSys: [PathBtwn]
    
    @ObservedObject var locationGetter = LocationGetterModel()
    
    var body: some View {
        NavigationView {
            ScrollView (.horizontal, showsIndicators: false) {
                HStack (spacing: 10) {
                    NavigationLink(destination: MapPage(locations: $locations, trajectories: $trajectories, lineSegments: $lineSegments, representatives: $representatives, p: $p, mapSys: $mapSys, locationGetter: locationGetter)) {
                        ZStack {
                            Image("map")
                                .resizable()
                                .frame(width: SCWidth * 0.25, height: SCWidth * 0.25) // 1 = SCWidth * 0.001
                                .cornerRadius(SCWidth * 0.02)
                            
                            VStack(alignment: .leading) {
                                Text("Map")
                                    .foregroundColor(Color.white) .shadow(color: Color.black, radius: SCWidth * 0.003, x: SCWidth * 0.003, y: SCWidth * 0.003)
                                    .font(.system(size: SCWidth * 0.06, weight: .bold, design: .rounded))
                                 
                            }.offset(x: -SCWidth * 0.03, y: SCWidth * 0.08)
                            
                        }.frame(alignment: .center) .padding(.leading, SCWidth * 0.03)
                    }
                
                    NavigationLink(destination: LocationPage(locations: $locations)) {
                        ZStack {
                            Image("building")
                                .resizable()
                                .frame(width: SCWidth * 0.25, height: SCWidth * 0.25)
                                .cornerRadius(SCWidth * 0.02)
                            
                            VStack(alignment: .leading) {
                                Text("Location")
                                    .foregroundColor(Color.white).shadow(color: Color.black, radius: SCWidth * 0.003, x: SCWidth * 0.003, y: SCWidth * 0.003)
                                    .font(.system(size: SCWidth * 0.055, weight: .bold, design: .rounded))
                                   
                            }.offset(x: -SCWidth * 0.01, y: SCWidth * 0.08)
                        }.frame(alignment: .center).padding(.trailing, SCWidth * 0.03)
                    }.padding(.leading, SCWidth * 0.03)
                }
                .padding(.top, SCWidth * 0.02)
                .navigationTitle("Home")
            }
        }
    }
}
