//
//  Home.swift
//  CUMap
//
//  Created by Study on 20/1/2021.
//

import SwiftUI

struct Home : View {
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

    @State var width = UIScreen.main.bounds.width - 90
    // to hide view...
 
    
    var body: some View{
        
        ZStack(alignment: Alignment(horizontal: .leading, vertical: .center)) {
           
            MainPage(locations: locations, routes: routes, x: $x, locationGetter: locationGetter)
            
            SlideMenu()
                .shadow(color: Color.black.opacity(x != 0 ? 0.1 : 0), radius: 5, x: 5, y: 0)
                .offset(x: x)
                .background(Color.black.opacity(x == 0 ? 0.5 : 0).ignoresSafeArea(.all, edges: .vertical).onTapGesture {
                    
                    withAnimation{
                        
                        x = -width
                    }
                })
        }
        // adding gesture or drag feature...
        .gesture(DragGesture().onChanged({ (value) in
            
            withAnimation{
                
                if value.translation.width > 0{
                    
                    // disabling over drag...
                    
                    if x < 0{
                        
                        x = -width + value.translation.width
                    }
                }
                else{

                    if x != -width{
                    
                        x = value.translation.width
                    }
                }
            }
            
        }).onEnded({ (value) in
            
            withAnimation{
                
                // checking if half the value of menu is dragged means setting x to 0...
                
                if -x < width / 2{
                    
                    x = 0
                }
                else{
                    
                    x = -width
                }
            }
        }))
    }
}

struct SlideMenu : View {
    
    var edges = UIApplication.shared.windows.first?.safeAreaInsets
    @State var show = true
    
    var body: some View{
        
        HStack(spacing: 0){
            
            VStack(alignment: .leading){
                
                
                
                HStack(alignment: .top, spacing: 12) {
                    
                    VStack(alignment: .leading, spacing: 12) {
                        
                        
                        HStack(spacing: 20){
                            Text("CU Map")
                                .foregroundColor(Color(red: 177/255, green: 149/255, blue: 165/255))
                                .font(.system(.body, design: .rounded))
                                .bold()
                        }
                        .padding(.top,10)
                        
                        Divider()
                            .padding(.top,10)
                    }
                    
                    Spacer(minLength: 0)
                    
             
                }
                
               
                
                VStack(alignment: .leading){
                 
                    // Menu Buttons....
                    
                    ForEach(menuButtons,id: \.self){menu in
                        
                        Button(action: {
                            // switch your actions or work based on title....
                        }) {
                            
                            MenuButton(title: menu)
                        }
                    }
                    
                    Divider()
                        .padding(.top)
                    
                    Button(action: {
                        // switch your actions or work based on title....
                    }) {
                        
                        MenuButton(title: "Contact With Us")
                    }
                    
                    Divider()
                    
                    Button(action: {}) {
                        
                        Text("Settings and privacy")
                            .foregroundColor(Color(red: 177/255, green: 149/255, blue: 165/255))
                    }
                    .padding(.top)
                    
                   
                    .padding(.top,20)
                    
                    Spacer(minLength: 0)
                    
                    Divider()
                        .padding(.bottom)
                    
                    HStack{
                        
                        Button(action: {}) {
                            
                            Image("help")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 26, height: 26)
                                .foregroundColor(Color("twitter"))
                        }
                        
                        Spacer(minLength: 0)
                        
                        Button(action: {}) {
                            
                            Image("barcode")
                                .renderingMode(.template)
                                .resizable()
                                .frame(width: 26, height: 26)
                                .foregroundColor(Color("twitter"))
                        }
                    }
                }
                // hiding this view when down arrow pressed...
                .opacity(show ? 1 : 0)
                .frame(height: show ? nil : 0)
                
           
                
            }
            .padding(.horizontal,20)
            // since vertical edges are ignored....
            .padding(.top,edges!.top == 0 ? 15 : edges?.top)
            .padding(.bottom,edges!.bottom == 0 ? 15 : edges?.bottom)
            // default width...
            .frame(width: UIScreen.main.bounds.width - 90)
            .background(Color.white)
            .ignoresSafeArea(.all, edges: .vertical)
            
            Spacer(minLength: 0)
        }
    }

var menuButtons = ["Favourite","Buildings","Bus Stops","Others"]

struct MenuButton : View {
    
    var title : String
    
    var body: some View{
        
        HStack(spacing: 15){
           
            // both title and image names are same....
            Image(title)
                .resizable()
                .renderingMode(.template)
                .frame(width: 24, height: 24)
                .foregroundColor(Color(red: 177/255, green: 149/255, blue: 165/255))
            
            Text(title)
                .foregroundColor(Color(red: 177/255, green: 149/255, blue: 165/255))
            
            Spacer(minLength: 0)
        }
        .padding(.vertical,20)
    }
}
}
