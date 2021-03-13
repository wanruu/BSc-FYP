import SwiftUI

struct LocDetailsView: View {
    @Binding var locations: [Location]
    @Binding var loc: Location?
    
    // for editing
    @State var id = ""
    @State var nameEn = ""
    @State var nameZh = ""
    @State var latitude = ""
    @State var longitude = ""
    @State var altitude = ""
    @State var type = ""
    @State var isEditing = false
    
    let width = UIScreen.main.bounds.width * 0.24
    
    var body: some View {
        if let loc = loc {
            VStack(alignment: .leading, spacing: 0) {
                title
                
                buttons
                Divider()
                info
            }.onAppear {
                id = loc.id
                nameEn = loc.nameEn
                nameZh = loc.nameZh
                latitude = String(loc.latitude)
                longitude = String(loc.longitude)
                altitude = String(loc.altitude)
                type = String(loc.type.toInt())
            }
        }
    }
    
    var title: some View {
        VStack(alignment: .leading) {
            Text(loc!.nameEn).font(.headline)
            Text(loc!.type.toString()).font(.subheadline)
        }
        .padding()
    }
    
    var buttons: some View {
        ScrollView(.horizontal) {
            HStack {
                Button(action: {
                    deleteLocation()
                }) {
                    HStack(spacing: 3) {
                        Image(systemName: "xmark")
                        Text(NSLocalizedString("button.delete", comment: "")).bold()
                    }
                    .foregroundColor(Color.white)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 5)
                    .background(RoundedRectangle(cornerRadius: 20).fill(Color.red))
                }
                
                if isEditing {
                    Button(action: {
                        editLocation()
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "checkmark")
                            Text(NSLocalizedString("button.save", comment: "")).bold()
                        }
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.green))
                    }
                } else {
                    Button(action: {
                        isEditing.toggle()
                    }) {
                        HStack(spacing: 3) {
                            Image(systemName: "pencil")
                            Text(NSLocalizedString("button.edit", comment: "")).bold()
                        }
                        .foregroundColor(Color.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 5)
                        .background(RoundedRectangle(cornerRadius: 20).fill(Color.accentColor))
                    }
                }
            }.padding(.horizontal).padding(.bottom)
        }
    }
    
    var info: some View {
        ScrollView {
            VStack(spacing: 10) {
                EditItem(title: "ID", text: $id, isEditing: $isEditing, width: width, disabled: true)
                EditItem(title: "English name", text: $nameEn, isEditing: $isEditing, width: width)
                EditItem(title: "Chinese name", text: $nameZh, isEditing: $isEditing, width: width)
                EditItem(title: "latitude", text: $latitude, isEditing: $isEditing, width: width)
                EditItem(title: "longitude", text: $longitude, isEditing: $isEditing, width: width)
                EditItem(title: "altitude", text: $altitude, isEditing: $isEditing, width: width)
                HStack {
                    Text(NSLocalizedString("type", comment: "")).lineLimit(1).minimumScaleFactor(0.3).frame(width: width, alignment: .leading)
                    if isEditing {
                        TextField("", text: $type)
                            .padding(10).overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.secondary, lineWidth: 0.5))
                    } else {
                        Spacer()
                    }
                    let num = Int(type) ?? -1
                    Text(num.isValidLocationType() ? num.toLocationType().toString() : NSLocalizedString("invalid", comment: ""))
                        .lineLimit(1).minimumScaleFactor(0.3)
                        .frame(width: width, alignment: .center)
                }
            }
            .padding()
        }
    }
    
    
    struct EditItem: View {
        var title: String
        @Binding var text: String
        @Binding var isEditing: Bool
        
        let width: CGFloat
        var disabled: Bool = false
        
        var body: some View {
            HStack {
                Text(NSLocalizedString(title, comment: "")).lineLimit(1).minimumScaleFactor(0.3).frame(width: width, alignment: .leading)
                if isEditing {
                    TextField("", text: $text)
                        .disabled(disabled).foregroundColor(disabled ? Color.secondary : Color.primary)
                        .padding(10).overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.secondary, lineWidth: 0.5))
                } else {
                    text.isEmpty ?
                    Text("(" + NSLocalizedString("blank", comment: "") + ")")
                        .italic().foregroundColor(Color.secondary)
                        .frame(maxWidth: .infinity, alignment: .trailing) :
                    Text(text)
                        .italic().foregroundColor(Color.primary)
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
    }
    
    private func deleteLocation() {
        let data = ["_id": id]
        let jsonData = try? JSONSerialization.data(withJSONObject: data)
        let url = URL(string: server + "/location")!
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.httpBody = jsonData
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            do {
                let res = try JSONDecoder().decode(DeleteResult.self, from: data)
                if(res.deletedCount == 1) {
                    locations.removeAll(where: { $0.id == id })
                    loc = nil
                }
            } catch let error {
                print(error)
            }
        }.resume()
    }
    
    private func editLocation() {
        let locRes = LocResponse(_id: id, name_en: nameEn, name_zh: nameZh, latitude: Double(latitude)!, longitude: Double(longitude)!, altitude: Double(altitude)!, type: Int(type)!)
        do {
            let jsonData = try JSONEncoder().encode(locRes)
            let url = URL(string: server + "/location")!
            var request = URLRequest(url: url)
            request.httpBody = jsonData
            request.httpMethod = "PUT"
            request.addValue("application/json", forHTTPHeaderField: "Content-Type")
            
            URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data else { return }
                do {
                    let res = try JSONDecoder().decode(PutResult.self, from: data)
                    if res.nModified == 1 {
                        let index = locations.firstIndex(where: { $0.id == id })!
                        locations[index].nameEn = nameEn
                        locations[index].nameZh = nameZh
                        locations[index].latitude = Double(latitude)!
                        locations[index].longitude = Double(longitude)!
                        locations[index].altitude = Double(altitude)!
                        locations[index].type = Int(type)!.toLocationType()
                        isEditing.toggle()
                    } else if res.nModified == 0 {
                        isEditing.toggle()
                    }
                } catch let error {
                    print(error)
                }
            }.resume()
        } catch let error {
            print(error)
        }
    }
}

