

import Foundation
import SwiftUI

let LocationTypes = ["Bus stop", "Building"]

func StringToInt(string: String) -> Int {
    return Int(string) ?? -1
}
func isValidType(string: String) -> Bool {
    let index = StringToInt(string: string)
    if(index >= 0 && index < LocationTypes.count) {
        return true
    }
    return false
}

struct FunctionSheet: View {
    @Environment(\.managedObjectContext) private var viewContext
    @State var locationName: String = ""
    @State var locationType: String = ""
    
    @ObservedObject var locationGetter: LocationGetterModel
    @State var locations: FetchedResults<Location>
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
            
            /* add location function */
            VStack {
                Text("Add a location")
                TextField( "Location Name", text: $locationName).textFieldStyle(RoundedBorderTextFieldStyle())
                HStack {
                    TextField( "Location Type", text: $locationType).textFieldStyle(RoundedBorderTextFieldStyle())
                    isValidType(string: locationType) ? Text("\(LocationTypes[StringToInt(string: locationType)])") : Text("Invalid")
                }
                Button(action: {
                    guard locationName != "" && isValidType(string: locationType) else { return }
                    addLocation()
                    locationName = ""
                    locationType = ""
                } ){ Text("Add") }
            }
            
            /* location list */
            ForEach(locations) { (location: Location) in
                VStack(alignment: .leading) {
                    Text("\(location.name_en) (\(LocationTypes[location.type]))").font(.headline)
                    Text("(\(location.latitude), \(location.longitude))").font(.subheadline)
                }
            }
            .onDelete { indexSet in
                deleteLocations(offsets: indexSet)
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
    /* add current location to location list */
    private func addLocation() {
        let newLocation = Location(context: viewContext)
        /* location information */
        newLocation.name_en = locationName
        newLocation.latitude = locationGetter.current.coordinate.latitude
        newLocation.longitude = locationGetter.current.coordinate.longitude
        newLocation.altitude = locationGetter.current.altitude
        newLocation.type = StringToInt(string: locationType)
        do { try viewContext.save() }
        catch { fatalError("Error in addLocation.") }
    }
    private func deleteLocations(offsets: IndexSet) {
        offsets.map { locations[$0] }.forEach(viewContext.delete)
        do { try viewContext.save() }
        catch { fatalError("Error in deleteLocations.") }
    }
    private func deleteRawPaths(offsets: IndexSet) {
        offsets.map { rawPaths[$0] }.forEach(viewContext.delete)
        do { try viewContext.save() }
        catch { fatalError("Error in deleteRawPaths.") }
    }
}

