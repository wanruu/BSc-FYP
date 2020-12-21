/* MARK: Location Page - a list of locations */

import Foundation
import SwiftUI

struct LocationPage: View {
    @Binding var locations: [Location]
    @State var showedLocation: Location? = nil
    
    @State var offset: Offset = Offset(x: 0, y: 0)
    @State var lastOffset = Offset(x: 0, y: 0)
    @State var scale: CGFloat = minZoomOut
    @State var lastScale = minZoomOut
    
    @State var showList = false

    var body: some View {
        ZStack {
            Image("cuhk-campus-map")
            .resizable()
            .frame(width: 3200 * scale, height: 3200 * 25 / 20 * scale, alignment: .center)
            .position(x: centerX + offset.x, y: centerY + offset.y)
            
            LocationsView(locations: $locations, showedLocation: $showedLocation, offset: $offset, scale: $scale)
        }
        .contentShape(Rectangle())
        .highPriorityGesture(SimultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    var tmpScale = lastScale * value.magnitude
                    if(tmpScale < minZoomOut) {
                        tmpScale = minZoomOut
                    } else if(tmpScale > maxZoomIn) {
                        tmpScale = maxZoomIn
                    }
                    scale = tmpScale
                    offset = lastOffset * tmpScale / lastScale
                }
                .onEnded { _ in
                    lastScale = scale
                    lastOffset.x = offset.x
                    lastOffset.y = offset.y
                },
            DragGesture()
                .onChanged{ value in
                    offset.x = lastOffset.x + value.location.x - value.startLocation.x
                    offset.y = lastOffset.y + value.location.y - value.startLocation.y
                }
                .onEnded{ _ in
                    lastOffset.x = offset.x
                    lastOffset.y = offset.y
                }
            )
        )
        // navigation bar
        .navigationTitle("Location")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(action: {showList = true}) {Image(systemName: "list.bullet").imageScale(.large)} )
        // list
        .sheet(isPresented: $showList) {
            NavigationView {
                List {
                    ForEach(locations) { location in
                        Button(action: {
                            showedLocation = location
                            showList = false
                            // move selected location to center
                            scale = maxZoomIn
                            lastScale = maxZoomIn
                            offset.x = CGFloat((centerLg - location.longitude)*lgScale*2) * scale
                            offset.y = CGFloat((location.latitude - centerLa)*laScale*2) * scale
                            lastOffset = offset
                        }) {
                            HStack {
                                Image(systemName: location.type == 0 ? "building.2" : "bus")
                                VStack(alignment: .leading) {
                                    Text(location.name_en).font(.headline)
                                    Text("(\(location.latitude), \(location.longitude), \(location.altitude)").font(.subheadline)
                                }
                            }
                        }
                    }.onDelete { offsets in
                        let index = offsets.first!
                        deleteLocation(location: locations[index], index: index)
                    }
                }
                .navigationTitle("Location List")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button(action: { showList = false }) { Text("Cancel") })
            }
        }
    }
    
    private func deleteLocation(location: Location, index: Int) {
        /* data */
        let dataStr = "name_en=" + location.name_en + "&type=" + String(location.type)
        
        let url = URL(string: server + "/location")!
        var request = URLRequest(url: url)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"
        request.httpBody = dataStr.data(using: String.Encoding.utf8)
        
        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            if(error != nil) {
                print("error")
            } else {
                guard let data = data else { return }
                do {
                    let res = try JSONDecoder().decode(LocResponse.self, from: data)
                    if(res.success) {
                        locations.remove(at: index)
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

