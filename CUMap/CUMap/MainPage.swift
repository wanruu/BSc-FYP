/*
    MainPage.
    ---------------------
    |    Search View    |
    ---------------------
    |                   |
    |     Map View      |
    |                   |
    ---------------------
    |  Plans Text View  |
    ---------------------
 
 */

import Foundation
import SwiftUI

// MARK: - MapPage
struct MainPage: View {
    // data used to do route planning
    @State var locations: [Location]
    @State var routes: [Route]
    
    //showing menu tab
    @Binding var x : CGFloat
    
    @ObservedObject var locationGetter: LocationGetterModel
    
    // search result
    @State var plans: [Plan] = []
    @State var planIndex: Int = 0
    @State var mode: TransMode = .bus
    
    // height of plan view
    @State var lastHeight: CGFloat = -UIScreen.main.bounds.height * 0.1
    @State var height: CGFloat = -UIScreen.main.bounds.height * 0.1
    

var body: some View{
    
    // Home View With CUstom Nav bar...
    
    VStack{
        
        ZStack{
        MapView(plans: $plans, planIndex: $planIndex, locationGetter: locationGetter, lastHeight: $lastHeight, height: $height)
      
        PlansView(plans: $plans, planIndex: $planIndex, lastHeight: $lastHeight, height: $height)
       
        SearchView(locationGetter: locationGetter, locations: locations, routes: routes, plans: $plans, planIndex: $planIndex, mode: $mode, lastHeight: $lastHeight, height: $height)
           
            VStack {
             
                HStack{
                    
                    Button(action: {
                        withAnimation{
                            x = 0
                        }
                        
                    }) {
                        Image("menu-button")
                            .resizable()
                            .frame(width:20, height: 20)
                    }
                    Spacer(minLength: 0)
                    Text("CU Map")
                        .foregroundColor(Color(red: 177/255, green: 149/255, blue: 165/255))
                        .font(.system(.body, design: .rounded))
                        .bold()
                        .padding(.trailing, 25)
                    
                    Spacer(minLength: 0)
                }
                .padding(.top,50)
                .padding(.bottom, 10)
                .padding(.leading, 21)
                .background(Color(red: 119/255, green: 114/255, blue: 148/255))
                .shadow(color: Color.black.opacity(0.1), radius: 5, x: 0, y: 5)
                .offset(x: 0, y: -460)
            }
         
        }.offset(x: 0, y: 20)
   
        }
    
 
}

}
