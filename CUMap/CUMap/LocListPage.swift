//
//  LocListPage.swift
//  CUMap
//
//  Created by wanruuu on 22/2/2021.
//

import SwiftUI

struct LocListPage: View {
    // search box
    @State var placeholder: String
    @State var keyword: String
    
    // location list
    @State var locations: [Location]
    @State var showCurrent: Bool
    
    // chosen location
    @Binding var location: Location?
    
    @Binding var showing: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // text field
            HStack(spacing: 20) {
                Image(systemName: "chevron.backward")
                    .imageScale(.large)
                    .onTapGesture {
                        showing.toggle()
                    }
                TextField(placeholder, text: $keyword)
                keyword == "" ? nil : Image(systemName: "xmark").imageScale(.large).onTapGesture { keyword = "" }
            }
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray, lineWidth: 0.8))
            .padding()

            Divider()
            
            // list
            ScrollView {
                VStack(spacing: 0) {
                    // current location
                    showCurrent ? Button(action: {
                        self.location = Location(_id: UUID().uuidString, name_en: "Your Location", latitude: -1, longitude: -1, altitude: -1, type: 0)
                        showing.toggle()
                    }) {
                        HStack(spacing: 20) {
                            Image(systemName: "location.fill")
                                .imageScale(.large)
                                .foregroundColor(Color.blue)
                                
                            Text("Your Location")
                            Spacer()
                        }
                        .padding(.horizontal)
                        .contentShape(Rectangle())
                    }.buttonStyle(MyButtonStyle()) : nil
                    
                    showCurrent ? Divider().padding(.horizontal) : nil
                    // other locations
                    ForEach(locations) { location in
                        if keyword == "" || location.name_en.lowercased().contains(keyword.lowercased()) {
                            Button(action: {
                                self.location = location
                                showing.toggle()
                            }) {
                                HStack(spacing: 20) {
                                    if location.type == 0 {
                                        Image(systemName: "building.2.fill")
                                            .imageScale(.large)
                                            .foregroundColor(CUPurple)
                                    } else if location.type == 1 {
                                        Image(systemName: "bus")
                                            .imageScale(.large)
                                            .foregroundColor(CUYellow)
                                    }
                                    Text(location.name_en)
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .contentShape(Rectangle())
                            }.buttonStyle(MyButtonStyle())
                            Divider().padding(.horizontal)
                        }
                    }
                }
            }
            // end of scrollview
        }.navigationBarHidden(true)
    }
}
