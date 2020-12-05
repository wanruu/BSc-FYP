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
         
                HStack () {
                   
                    NavigationLink(destination: MapPage(locations: $locations, trajectories: $trajectories, lineSegments: $lineSegments, representatives: $representatives, p: $p, locationGetter: locationGetter)) {
                        ZStack {
                            
                            Image("map")
                                .resizable()
                                .cornerRadius(20)
                            
                            VStack(alignment: .leading) {
                                Text("Map")
                                    .foregroundColor(Color.white) .shadow(color: Color.black, radius: 3, x: 3, y: 3)
                                    .font(.system(size: UIScreen.main.bounds.width * 0.08, weight: .bold, design: .rounded)).offset(x:-UIScreen.main.bounds.width * 0.045,y:UIScreen.main.bounds.width * 0.12)
                                 
                            }
                        }.frame(width: UIScreen.main.bounds.width * 0.40, height:  UIScreen.main.bounds.width * 0.40)
                        }.padding(.leading, UIScreen.main.bounds.width * 0.05)
                       
                    NavigationLink(destination: LocationPage(locations: $locations)) {
                       
                        ZStack {
                            Image("building")
                                .resizable()
                                .cornerRadius(20)
                            
                            VStack(alignment: .leading) {
                                Text("Building")
                                    .foregroundColor(Color.white).shadow(color: Color.black, radius: 3, x: 3, y: 3)
                                    .font(.system(size: UIScreen.main.bounds.width * 0.08, weight: .bold, design: .rounded)).offset(x:-UIScreen.main.bounds.width * 0.015,y:UIScreen.main.bounds.width * 0.12)
                                   
                            }
                        }.frame(width: UIScreen.main.bounds.width * 0.40, height:  UIScreen.main.bounds.width * 0.40)
                        
                }.padding(.trailing, UIScreen.main.bounds.width * 0.05 ).padding(.leading, UIScreen.main.bounds.width * 0.03 )
         
              
            
        }
                .navigationTitle("Home")
    }
      
}
    }
