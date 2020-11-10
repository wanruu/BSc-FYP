

import Foundation
import SwiftUI

struct FunctionSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var buildingName: String = ""
    @ObservedObject var locationGetter: LocationGetterModel
    @State var buildings: FetchedResults<Building>
    @State var rawPaths: FetchedResults<RawPath>
    
    @Binding var showCurrentLocation: Bool
    @Binding var showRawPaths: Bool
    @Binding var showBuildings: Bool
    @Binding var showClusters: Bool
    @Binding var showRepresentatives: Bool
    
    var body: some View {
        List {
            Toggle(isOn: $showCurrentLocation, label: { Text("Show Current Location") })
            Toggle(isOn: $showRawPaths, label: { Text("Show Raw Paths") })
            Toggle(isOn: $showBuildings, label: { Text("Show Buildings") })
            Toggle(isOn: $showClusters, label: { Text("Show Clusters") })
            Toggle(isOn: $showRepresentatives, label: { Text("Show Representatives") })
            /* add building function */
            HStack {
                TextField( "Name of the building", text: $buildingName).textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    guard buildingName != "" else { return }
                    addBuilding()
                    buildingName = ""
                } ){ Text("Add") }
            } .padding(.bottom)
            Divider()
            /* building list */
            ForEach(buildings) { building in
                VStack(alignment: .leading) {
                    Text(building.name_en).font(.headline)
                    Text("(\(building.latitude), \(building.longitude))").font(.subheadline)
                }
            }
            .onDelete { indexSet in
                deleteBuildings(offsets: indexSet)
            }
            Divider()
            /* rawPath list */
            ForEach(rawPaths) { rawPath in
                let locations = rawPath.locations
                locations.count == 0 ? nil :
                VStack(alignment: .leading) {
                    Text("(\(locations[0].coordinate.latitude), \(locations[0].coordinate.longitude)), \(formatter(date: locations[0].timestamp))")
                    Text("(\(locations[locations.count - 1].coordinate.latitude), \(locations[locations.count - 1].coordinate.longitude)), \(formatter(date: locations[locations.count - 1].timestamp))")
                    Text("\(locations.count)")
                }
            }.onDelete {
                indexSet in
                    deleteRawPaths(offsets: indexSet)
            }
        }
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
    private func deleteRawPaths(offsets: IndexSet) {
        offsets.map { rawPaths[$0] }.forEach(viewContext.delete)
        do { try viewContext.save() }
        catch { fatalError("Error in deleteRawPaths.") }
    }
}

