//
//  BusListPage.swift
//  CUMap
//
//  Created by wanruuu on 22/2/2021.
//

import SwiftUI

struct BusListPage: View {
    // search box
    @State var placeholder: String
    @State var keyword: String
    
    // bus list
    @State var buses: [Bus]
    
    // chosen bus
    @Binding var bus: Bus?
    
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
                    ForEach(buses) { bus in
                        if keyword == "" || bus.name_en.lowercased().contains(keyword.lowercased()) || bus.id.lowercased().contains(keyword.lowercased()) {
                            Button(action: {
                                self.bus = bus
                                showing.toggle()
                            }) {
                                Text("\(bus.id)  \(bus.name_en)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
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

