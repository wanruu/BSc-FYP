//
//  ContentView.swift
//  CUMap
//
//  Created by wanruuu on 27/11/2020.
//

import SwiftUI
import CoreData

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Location.name_en, ascending: true)], animation: .default)
    private var locations: FetchedResults<Location>
    
    @State var page: Int = 0 // 0: main page, 1: search page (from), 2: search page (to)
    @State var start: String = ""
    @State var end: String = ""
    @ObservedObject var locationGetter = LocationGetterModel()
    
    var body: some View {
        page == 0 ? MainPage(page: $page, start: $start, end: $end, locationGetter: locationGetter) : nil
        page == 1 ? SearchPage(page: $page, locations: locations, result: $start) : nil
        page == 2 ? SearchPage(page: $page, locations: locations, result: $end) : nil
        
        // Button("Upload") { uploadLocations() }
    }

    private func uploadLocations() {
        for _ in 0..<locations.count {
            deleteLocations(offsets: IndexSet(integer: 0))
        }
        for location in locationData {
            addLocation(location: location)
        }
    }
    
    private func addLocation(location: LocationData) {
        withAnimation {
            let newLocation = Location(context: viewContext)
            newLocation.name_en = location.name_en
            newLocation.latitude = location.latitude
            newLocation.longitude = location.longitude
            newLocation.altitude = location.altitude
            newLocation.type = location.type
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }

    private func deleteLocations(offsets: IndexSet) {
        withAnimation {
            offsets.map { locations[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
