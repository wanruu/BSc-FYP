

import Foundation
import SwiftUI

struct FunctionSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var locationName: String = ""
    @ObservedObject var locationGetter: LocationGetterModel
    @State var locations: [Location]
    @State var rawPaths: FetchedResults<RawPath>
    
    @Binding var showCurrentLocation: Bool
    @Binding var showRawPaths: Bool
    @Binding var showLocations: Bool
    @Binding var showClusters: Bool
    @Binding var showRepresentatives: Bool
    
    var body: some View {
        List {
            Toggle(isOn: $showCurrentLocation, label: { Text("Show Current Location") })
            Toggle(isOn: $showRawPaths, label: { Text("Show Raw Paths") })
            Toggle(isOn: $showLocations, label: { Text("Show Locations") })
            Toggle(isOn: $showClusters, label: { Text("Show Clusters") })
            Toggle(isOn: $showRepresentatives, label: { Text("Show Representatives") })
            /* add building function */
            HStack {
                TextField( "Name of the building", text: $locationName).textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    guard locationName != "" else { return }
                    // addBuilding()
                    locationName = ""
                } ){ Text("Add") }
            } .padding(.bottom)
            Divider()
            /* building list */
            ForEach(0..<locations.count) { i in
                VStack(alignment: .leading) {
                    Text(locations[i].name_en).font(.headline)
                    Text("(\(locations[i].latitude), \(locations[i].longitude))").font(.subheadline)
                }
            }
            .onDelete { indexSet in
                // MARK: ???????
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
            }.onDelete { indexSet in
                // MARK: ???????
            }
        }
    }
}

