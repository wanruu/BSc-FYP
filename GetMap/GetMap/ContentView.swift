//
//  ContentView.swift
//  GetMap
//
//  Created by wanruuu on 24/10/2020.
//

import SwiftUI
import CoreData
import Foundation

struct ContentView: View {
    /* core data */
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [], animation: .default)
    var rawPaths: FetchedResults<RawPath>
    
    /* from server */
    @State var locations: [Location] = []
    
    var body: some View {
        MainPage(rawPaths: rawPaths, locations: $locations)
            .onAppear {
                loadLocationData()
            }
    }
    
    // MARK: - Request to Server
    private func loadLocationData() {
        let url = URL(string: server + "/locations")!
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

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct Response: Codable {
    let operation: String
    let target: String
    let success: Bool
    let data: [Location]
}
