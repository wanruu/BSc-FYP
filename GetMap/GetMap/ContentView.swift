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
    /* from server */
    @State var locations: [Location] = []
    @State var trajectories: [[Coor3D]] = []
    @State var representatives: [[Coor3D]] = []
    
    var body: some View {
        MainPage(locations: $locations, trajectories: $trajectories, representatives: $representatives)
            .onAppear {
                loadLocations()
                loadTrajs()
            }
    }
    // MARK: - Load data from Server
    private func loadLocations() {
        let url = URL(string: server + "/locations")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let res = try JSONDecoder().decode(LocResponse.self, from: data)
                if(res.success) {
                    locations =  res.data
                }
            } catch let error {
                print(error)
            }
        }.resume()
    }
    private func loadTrajs() {
        let url = URL(string: server + "/trajectories")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let res = try JSONDecoder().decode(TrajResponse.self, from: data)
                if(res.success) {
                    trajectories =  res.data
                }
            } catch let error {
                print(error)
            }
        }.resume()
    }
    // MARK: - Upload data to Server
    private func uploadTraj(traj: [Coor3D]) {
        var items: [[String: Any]] = []
        for point in traj {
            items.append(["latitude": point.latitude, "longitude": point.longitude, "altitude": point.altitude])
        }
        let json = ["points": items]
        let jsonData = try? JSONSerialization.data(withJSONObject: json)
        let url = URL(string: server + "/trajectory")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            if(error != nil) {
                print("error")
            } else {
                guard let data = data else { return }
                do {
                    let res = try JSONDecoder().decode(TrajResponse.self, from: data)
                    if(res.success) {
                        print("success")
                    } else {
                        print("error")
                    }
                } catch let error {
                    print(error)
                }
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}

struct LocResponse: Codable {
    let operation: String
    let target: String
    let success: Bool
    let data: [Location]
}

struct TrajResponse: Codable {
    let operation: String
    let target: String
    let success: Bool
    let data: [[Coor3D]]
}
