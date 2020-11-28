//
//  LoadingPage.swift
//  GetMap
//
//  Created by wanruuu on 28/11/2020.
//

import Foundation
import SwiftUI

struct LoadingPage: View {

    @Binding var locations: [Location]
    
    var body: some View {
        Text("")
            .onAppear {
                loadLocationData()
            }
    }
    
    private func loadLocationData() {
        let url = URL(string: "http://10.13.115.254:8000/locations")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let res = try JSONDecoder().decode(Response.self, from: data)
                if(res.success) {
                    locations =  res.data
                }
            } catch let error {
                print(error)
            }
        }.resume()
    }
}


struct Response: Codable {
    let operation: String
    let target: String
    let success: Bool
    let data: [Location]
}
