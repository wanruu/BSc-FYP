//
//  SearchPage.swift
//  CUMap
//
//  Created by wanruuu on 27/11/2020.
//

import Foundation
import SwiftUI

struct SearchPage: View {
    @Binding var page: Int
    @State var locations: FetchedResults<Location>
    @Binding var result: String
    
    @State var keyword: String = ""
    
    var body: some View {
        UITextField.appearance().clearButtonMode = .whileEditing
        return
            VStack {
                /* searching bar */
                HStack {
                    /* back button */
                    Button(action: {
                        page = 0
                    }) { Text("Back") }.contentShape(Rectangle())
                    /* searching textfield */
                    page == 1 ?
                        TextField("From", text: $keyword).textFieldStyle(RoundedBorderTextFieldStyle()) :
                        TextField("To", text: $keyword).textFieldStyle(RoundedBorderTextFieldStyle())
                    /* confirm button */
                    Button(action: {
                        page = 0
                        result = keyword
                    }) { Text("Confirm") }.contentShape(Rectangle())
                }
                /* searching list */
                List {
                    ForEach(0 ..< locations.count) { value in
                        keyword == "" || locations[value].name_en.lowercased().contains(keyword.lowercased()) ?
                            Button(action: {
                                keyword = locations[value].name_en
                            } ){ Text(locations[value].name_en) } : nil
                    }
                }
            }.padding()
    }
}
