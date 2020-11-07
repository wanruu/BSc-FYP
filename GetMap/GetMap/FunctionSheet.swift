//
//  FunctionSheet.swift
//  GetMap
//
//  Created by wanruuu on 29/10/2020.
//

import Foundation
import SwiftUI

struct FunctionSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var buildingName: String = ""
    @ObservedObject var locationGetter: LocationGetterModel
    @State var buildings: FetchedResults<Building>
    
    @Binding var showCurrentLocation: Bool
    @Binding var showRawPaths: Bool
    @Binding var showBuildings: Bool
    
    var body: some View {
        VStack(alignment: .leading) {
            Toggle(isOn: $showCurrentLocation, label: {Text("Show Current Location")})
            Toggle(isOn: $showRawPaths, label: {Text("Show Raw Paths")})
            Toggle(isOn: $showBuildings, label: {Text("Show Buildings")})
            Divider()
            /* add building function */
            Text("Mark current location as a building")
            HStack {
                TextField( "Name of the building", text: $buildingName).textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    guard buildingName != "" else { return }
                    addBuilding()
                    buildingName = ""
                } ){ Text("Add") }
            } .padding(.bottom)
            /* show building list */
            Text("Building List")
            List {
                ForEach(buildings) { building in
                    VStack(alignment: .leading) {
                        Text(building.name_en).font(.headline)
                        Text("(\(building.latitude), \(building.longitude))").font(.subheadline)
                    }
                }
                .onDelete{ indexSet in
                    deleteBuildings(offsets: indexSet)
                }
            }
            Spacer()
        }.padding()
    }
    /* add current location to building list */
    private func addBuilding() {
        let newBuilding = Building(context: viewContext)
        /* building information */
        newBuilding.name_en = buildingName
        newBuilding.latitude = locationGetter.current.coordinate.latitude
        newBuilding.longitude = locationGetter.current.coordinate.longitude
        newBuilding.altitude = locationGetter.current.altitude
        do { try viewContext.save() }
        catch { fatalError("Error in addBuilding.") }
    }
    private func deleteBuildings(offsets: IndexSet) {
        offsets.map { buildings[$0] }.forEach(viewContext.delete)
        do { try viewContext.save() }
        catch { fatalError("Error in deleteBuildings.") }
    }
}

