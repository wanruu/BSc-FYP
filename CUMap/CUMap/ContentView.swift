//
//  ContentView.swift
//  CUMap
//
//  Created by wanruuu on 27/11/2020.
//

import Foundation
import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) var context
    @FetchRequest(sortDescriptors: []) var CDLocations: FetchedResults<CDLocation>
    @FetchRequest(sortDescriptors: []) var CDPaths: FetchedResults<CDPath>
    @FetchRequest(sortDescriptors: []) var CDversions: FetchedResults<CDVersion>
    
    @State var locations: [Location] = []
    @State var routes: [Route] = []
    @ObservedObject var locationGetter = LocationGetterModel()
    
    @State var loadTasks: [Bool] = [true, true]
    @State var newVersion: [Bool] = [false, false]
    @State var showAlert = false
    
    var body: some View {
        ZStack {
            loadTasks.filter{$0 == true}.count != loadTasks.count ? LoadPage(tasks: $loadTasks) : nil
            loadTasks.filter{$0 == true}.count != loadTasks.count ? nil : MainPage(locations: locations, routes: routes, locationGetter: locationGetter)
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
            // load(tasks: loadTasks)
        }
    }
    // MARK: - Core Data
    func saveContext() {
        do {
            try context.save()
        } catch {
            print("Error saving managed object context: \(error)")
        }
    }
    
    // MARK: - Load data
    private func load(tasks: [Bool]) {
        // check version
        /* let url = URL(string: server + "/versions")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if(error != nil) { showAlert = true }
            guard let data = data else { return }
            do {
                let res = try JSONDecoder().decode(VersionResponse.self, from: data)
                if(res.success) {
                    for newVersion in res.data {
                        for currentVersion in CDversions {
                            
                        }
                    }
                    loadTasks[0] = true
                } else { showAlert = true }
            } catch let error { showAlert = true }
        }.resume()*/
        
        for i in 0..<tasks.count {
            if(!tasks[i]) {
                switch i {
                    case 0: loadLocations()
                    case 1: loadRoutes()
                    default: return
                }
            }
        }
    }
    private func loadLocations() { // load task #0
        let url = URL(string: server + "/locations")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if(error != nil) { showAlert = true }
            guard let data = data else { return }
            do {
                locations = try JSONDecoder().decode([Location].self, from: data)
                loadTasks[0] = true
            } catch let error {
                showAlert = true
                print(error)
                print("task 0")
            }
        }.resume()
    }
    private func loadRoutes() { // load task #1
        let url = URL(string: server + "/routes")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            if(error != nil) {
                showAlert = true
            }
            guard let data = data else { return }
            do {
                routes = try JSONDecoder().decode([Route].self, from: data)
                loadTasks[1] = true
            } catch let error {
                showAlert = true
                print(error)
                print("task 1")
            }
        }.resume()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
