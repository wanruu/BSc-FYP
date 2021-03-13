import SwiftUI

struct NewLocView: View {
    @Binding var locations: [Location]
    @Binding var current: Coor3D
    
    // for editing
    @State var nameEn = ""
    @State var nameZh = ""
    @State var latitude = ""
    @State var longitude = ""
    @State var altitude = ""
    @State var type = ""
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text(NSLocalizedString("name", comment: ""))) {
                    TextField(NSLocalizedString("English name", comment: ""), text: $nameEn)
                    TextField(NSLocalizedString("Chinese name", comment: ""), text: $nameZh)
                }
                
                Section(header: Text(NSLocalizedString("location", comment: ""))) {
                    TextField(NSLocalizedString("latitude", comment: ""), text: $latitude)
                    TextField(NSLocalizedString("longitude", comment: ""), text: $longitude)
                    TextField(NSLocalizedString("altitude", comment: ""), text: $altitude)
                }
                
                let num = Int(type) ?? -1
                Section(
                    header: Text(NSLocalizedString("type", comment: "")),
                    footer: num.isValidLocationType() ? Text("* " + num.toLocationType().toString()).italic() :
                        Text("* " + NSLocalizedString("invalid", comment: "")).italic().foregroundColor(.red)
                ) {
                    TextField("", text: $type).keyboardType(.numberPad)
                }
                
                let disabled = nameEn.isEmpty || Double(latitude) == nil || Double(longitude) == nil || Double(altitude) == nil || !num.isValidLocationType()
                
                Button(action: {
                    createLoc()
                }) {
                    HStack {
                        Spacer()
                        Text(NSLocalizedString("button.confirm", comment: ""))
                        Spacer()
                    }
                }
                .disabled(disabled)
            }
            .listStyle(GroupedListStyle())
            .navigationTitle(Text(NSLocalizedString("new.location", comment: "")))
        }
        .onAppear {
            clean()
        }
    }
    
    private func clean() {
        nameEn = ""
        nameZh = ""
        latitude = String(current.latitude)
        longitude = String(current.longitude)
        altitude = String(current.altitude)
        type = "0"
    }
    
    private func createLoc() {
        let locRes = LocResponse(_id: "", name_en: nameEn, name_zh: nameZh, latitude: Double(latitude)!, longitude: Double(longitude)!, altitude: Double(altitude)!, type: Int(type)!)
        do {
            let jsonData = try JSONEncoder().encode(locRes)
            let url = URL(string: server + "/location")!
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.httpBody = jsonData
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            URLSession.shared.dataTask(with: request) { data, response, err in
                guard let data = data else { return }
                do {
                    let res = try JSONDecoder().decode(LocResponse.self, from: data)
                    locations.append(res.toLocation())
                    clean()
                } catch let error {
                    print(error)
                }
            }.resume()
        } catch let error {
            print(error)
        }
    }
}
