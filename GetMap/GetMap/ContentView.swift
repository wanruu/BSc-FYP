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
    
    @State var value = 0
    @State var total = 2
    
    @State var loadTasks = [Bool](repeating: false, count: 2)
    @State var showAlert = false
    var body: some View {
        ZStack {
            value != total ? LoadPage(value: $value, total: $total) : nil
            value != total ? nil : MainPage(locations: $locations, trajectories: $trajectories, representatives: $representatives)
        }
            .alert(isPresented: $showAlert) {
                Alert(
                    title: Text("Error"),
                    message: Text("Can not connect to server."),
                    dismissButton: Alert.Button.default(Text("Try again")) {
                        load(tasks: loadTasks)
                    }
                )
            }
            .onAppear {
                load(tasks: loadTasks)
           }
    }
    // MARK: - Load data from Server
    private func load(tasks: [Bool]) {
        for i in 0..<tasks.count {
            if(!tasks[i]) {
                switch i {
                    case 0:
                        loadLocations()
                    case 1:
                        loadTrajs()
                    default:
                        loadLocations()
                }
            }
        }
    }
    private func loadLocations() { // load task #0
        let url = URL(string: server + "/locations")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if(error != nil) {
                showAlert = true
            }
            guard let data = data else { return }
            do {
                let res = try JSONDecoder().decode(LocResponse.self, from: data)
                if(res.success) {
                    locations =  res.data
                    loadTasks[0] = true
                    value += 1
                } else {
                    showAlert = true
                }
            } catch let error {
                showAlert = true
                print(error)
            }
        }.resume()
    }
    private func loadTrajs() { // load task #1
        let url = URL(string: server + "/trajectories")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if(error != nil) {
                showAlert = true
            }
            guard let data = data else { return }
            do {
                let res = try JSONDecoder().decode(TrajResponse.self, from: data)
                if(res.success) {
                    trajectories =  res.data
                    loadTasks[1] = true
                    value += 1
                } else {
                    showAlert = true
                }
            } catch let error {
                showAlert = true
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
