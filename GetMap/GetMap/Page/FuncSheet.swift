//
//  FuncSheet.swift
//  GetMap
//
//  Created by wanruuu on 1/12/2020.
//

import Foundation
import SwiftUI

struct FuncSheet: View {
    @Binding var showCurrentLocation: Bool
    @Binding var showRawPaths: Bool
    @Binding var showLocations: Bool
    @Binding var showRepresentPaths: Bool
    
    @Binding var locations: [Location]
    @Binding var trajectories: [[Coor3D]]
    @Binding var representatives: [[Coor3D]]
    @ObservedObject var locationGetter: LocationGetterModel
    
    @State var locationName: String = ""
    @State var locationType: String = ""
    var body: some View {
        VStack {
            VStack {
                Text("New Location")
                TextField("Type of the building", text: $locationType)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                TextField( "Name of the building", text: $locationName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    guard locationName != "" else { return }
                    guard Int(locationType) != nil else { return }
                    addLocation()
                }) { Text("Add") }
            }.padding()
            List {
                Toggle(isOn: $showCurrentLocation) { Text("Show Current Location") }
                Toggle(isOn: $showRawPaths) { Text("Show Raw Paths") }
                Toggle(isOn: $showLocations) { Text("Show Locations") }
                Toggle(isOn: $showRepresentPaths) { Text("Show Representatives") }
            }
            List {
                Button(action: {
                    representatives = process(trajs: trajectories)
                }) { Text("Generate representative path") }
            }
        }
    }
    
    private func addLocation() {
        /* data */
        let latitude = locationGetter.current.coordinate.latitude
        let longitude = locationGetter.current.coordinate.longitude
        let altitude = locationGetter.current.altitude
        let type = Int(locationType)!
        let dataStr = "name_en=" + String(locationName) + "&latitude=" + String(latitude)  + "&longitude=" + String(longitude) + "&altitude=" + String(altitude) + "&type=" + String(type)
        
        let url = URL(string: server + "/location")!
        var request = URLRequest(url: url)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "PUT"
        request.httpBody = dataStr.data(using: String.Encoding.utf8)

        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if(error != nil) {
                print("error")
            } else {
                guard let data = data else { return }
                do {
                    let res = try JSONDecoder().decode(LocResponse.self, from: data)
                    if(res.success) {
                        let newLocation = Location(name_en: locationName, latitude: latitude, longitude: longitude, altitude: altitude, type: type)
                        locations.append(newLocation)
                        locationName = ""
                        locationType = ""
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
