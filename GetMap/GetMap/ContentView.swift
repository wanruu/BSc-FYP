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
    @State var lineSegments: [LineSeg] = []
    @State var representatives: [[Coor3D]] = []
    @State var p: [[Coor3D]] = []
    @State var mapSys: [PathBtwn] = []
    
    @State var loadTasks = [Bool](repeating: true, count: 2)
    @State var showAlert = false
    var body: some View {
        ZStack {
            loadTasks.filter{$0 == true}.count != loadTasks.count ? LoadPage(tasks: $loadTasks) : nil
            loadTasks.filter{$0 == true}.count != loadTasks.count ? nil : MainPage(locations: $locations, trajectories: $trajectories, lineSegments: $lineSegments, representatives: $representatives, p: $p, mapSys: $mapSys)
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
                //load(tasks: loadTasks)
           }
    }
    // MARK: - Load data from Server
    private func load(tasks: [Bool]) {
        for i in 0..<tasks.count {
            if(!tasks[i]) {
                switch i {
                    case 0: loadLocations()
                    case 1: loadTrajs()
                    default: loadLocations()
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
                } else {
                    showAlert = true
                }
            } catch let error {
                showAlert = true
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
