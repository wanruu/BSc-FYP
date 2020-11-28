/* MARK: Location Page - a list of locations */

import Foundation
import SwiftUI

struct LocationPage: View {
    @Binding var locations: [Location]
    var body: some View {
        List {
            ForEach(locations) { location in
                HStack {
                    Text(String(location.type)).font(.headline)
                    VStack(alignment: .leading) {
                        Text(location.name_en).font(.headline)
                        Text("(\(location.latitude), \(location.longitude))").font(.subheadline)
                    }
                }
            }.onDelete { offsets in
                let index = offsets.first!
                deleteLocation(location: locations[index], index: index)
            }
        }
        .navigationTitle("Location List")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func deleteLocation(location: Location, index: Int) {
        /* data */
        let dataStr = "name_en=" + location.name_en + "&type=" + String(location.type)
        
        let url = NSURL(string: server + "/location")
        let request = NSMutableURLRequest(url: url! as URL)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"
        request.httpBody = dataStr.data(using: String.Encoding.utf8)
        let session = URLSession(configuration: URLSessionConfiguration.default, delegate: nil, delegateQueue: nil)
        
        session.dataTask(with: request as URLRequest) { data, response, error in
            if(error != nil) {
                print("error")
            } else {
                guard let data = data else { return }
                do {
                    let res = try JSONDecoder().decode(Response.self, from: data)
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

