import SwiftUI

struct NewLocView: View {
    @Binding var locations: [Location]
    @Binding var selectedLoc: Location?
    
    // for editing
    @State var nameEn = ""
    @State var nameZh = ""
    @State var latitude = ""
    @State var longitude = ""
    @State var altitude = ""
    @State var type = ""
    
    @Binding var pageType: LocPageType
    
    let width = UIScreen.main.bounds.width * 0.24
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack {
                Button(action: {
                    pageType = .locList
                }) {
                    HStack {
                        Image(systemName: "arrow.uturn.backward")
                        Text("Back")
                    }
                }
                Spacer()
                Text(NSLocalizedString("New location", comment: ""))
                    .bold()
                    .lineLimit(1)
                    .minimumScaleFactor(0.3)
                Spacer()
                let disabled = Double(latitude) == nil || Double(longitude) == nil || Double(altitude) == nil || !(Int(type) ?? -1).isValidLocationType()
                
                
                Button(action: {
                    uploadLoc()
                }) {
                    HStack {
                        Image(systemName: "checkmark")
                        Text("OK")
                    }.foregroundColor(disabled ? Color.secondary : Color.green)
                }
                .disabled(disabled)
            }
            .padding()
            
            
            ScrollView(.vertical, showsIndicators: false) {
                VStack(spacing: 10) {
                    NewItem(title: "English name", text: $nameEn, width: width)
                    NewItem(title: "Chinese name", text: $nameZh, width: width)
                    NewItem(title: "Latitude", text: $latitude, width: width)
                    NewItem(title: "Longitude", text: $longitude, width: width)
                    NewItem(title: "Altitude", text: $altitude, width: width)
                    HStack {
                        Text(NSLocalizedString("Type", comment: "")).lineLimit(1).minimumScaleFactor(0.3).frame(width: width, alignment: .leading)
                        TextField("", text: $type)
                            .padding(10).overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.secondary, lineWidth: 0.5))
                        
                        let num = Int(type) ?? -1
                        Text(num.isValidLocationType() ? num.toLocationType().toString() : NSLocalizedString("Invalid", comment: ""))
                            .lineLimit(1).minimumScaleFactor(0.3)
                            .frame(width: width, alignment: .center)
                    }
                }
                .padding()
            }
        }
    }
    struct NewItem: View {
        var title: String
        @Binding var text: String
        
        let width: CGFloat

        var body: some View {
            HStack {
                Text(NSLocalizedString(title, comment: "")).lineLimit(1).minimumScaleFactor(0.3).frame(width: width, alignment: .leading)
                TextField("", text: $text)
                    .foregroundColor(Color.primary)
                    .padding(10).overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.secondary, lineWidth: 0.5))
            }
        }
    }
    
    private func uploadLoc() {
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
                    let loc = res.toLocation()
                    locations.append(loc)
                    selectedLoc = loc
                    pageType = .editLoc
                } catch let error {
                    print(error)
                }
            }.resume()
        } catch let error {
            print(error)
        }
    }
}
