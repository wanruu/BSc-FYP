import SwiftUI

struct NewBusView: View {
    @Binding var locations: [Location]
    @Binding var buses: [Bus]
    
    @State var id = ""
    @State var nameEn = ""
    @State var nameZh = ""
    
    @State var serviceDay = ServiceDay.ordinaryDay
    @State var startTime = Date()
    @State var endTime = Date()
    
    @State var departTime: [Int] = []
    @State var curDepartTime = ""
    
    @State var chosenStops: [Location] = []
    
    @State var showStopList: Bool = false
    @Binding var showing: Bool
    
    var body: some View {
        List {
            Section(header: Text(NSLocalizedString("Basic", comment: ""))) {
                TextField("ID", text: $id)
                TextField(NSLocalizedString("English name", comment: ""), text: $nameEn)
                TextField(NSLocalizedString("Chinese name", comment: ""), text: $nameZh)
            }
            
            Section(header: Text(NSLocalizedString("Service", comment: ""))) {
                Picker(selection: $serviceDay, label: Text("Service Day")) {
                    Text(NSLocalizedString("Mon - Sat", comment: "")).tag(ServiceDay.ordinaryDay)
                    Text(NSLocalizedString("Sun & Public holidays", comment: "")).tag(ServiceDay.holiday)
                    Text(NSLocalizedString("Teaching days only", comment: "")).tag(ServiceDay.teachingDay)
                }
                DatePicker(NSLocalizedString("Start at", comment: ""), selection: $startTime, displayedComponents: .hourAndMinute)
                DatePicker(NSLocalizedString("End at", comment: ""), selection: $endTime, displayedComponents: .hourAndMinute)
            }
            
            Section(header: Text(NSLocalizedString("Departs hourly at (mins)", comment: ""))) {
                ForEach(departTime) { depart in
                    Text(String(depart))
                }.onDelete(perform: { index in
                    departTime.remove(at: index.first!)
                })
                HStack {
                    TextField("", text: $curDepartTime).keyboardType(.numberPad)
                    Button(action: {
                        departTime.append(Int(curDepartTime)!)
                        curDepartTime = ""
                        // TODO: hide keyboard
                    }) {
                        Text(NSLocalizedString("Add", comment: ""))
                    }.disabled(curDepartTime.isEmpty || Int(curDepartTime) == nil || Int(curDepartTime)! < 0 || Int(curDepartTime)! > 60)
                }
            }
            
            Section(header: Text(NSLocalizedString("Bus stops", comment: ""))) {
                ForEach(chosenStops) { stop in
                    Text(stop.nameEn)
                }.onDelete(perform: { index in
                    chosenStops.remove(at: index.first!)
                })
                
                NavigationLink(destination: StopListArrayView(locations: $locations, chosenStops: $chosenStops, showing: $showStopList), isActive: $showStopList) {
                    HStack {
                        Image(systemName: "plus.circle.fill").imageScale(.large).foregroundColor(.green)
                        Text("New")
                    }
                }
            }
            
            Button(action: {
                createBus()
                id = ""
                nameEn = ""
                nameZh = ""
                serviceDay = .ordinaryDay
                departTime = []
                chosenStops = []
            }) {
                HStack {
                    Spacer()
                    Text("Confirm")
                    Spacer()
                }
            }
            .disabled(id.isEmpty || nameEn.isEmpty || departTime.isEmpty)
            
        }
        .listStyle(GroupedListStyle())
        .navigationTitle(Text("New Bus Route"))
    }
    private func createBus() {
        let bus = Bus(id: id, line: id, nameEn: nameEn, nameZh: nameZh, serviceHour: ServiceHour(startTime: startTime, endTime: endTime), serviceDay: serviceDay, departTime: departTime, stops: chosenStops)
        let busResponse = bus.toBusResponse()
        
        let jsonData = try? JSONEncoder().encode(busResponse)
        let url = URL(string: server + "/bus")!
        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "POST"
        request.httpBody = jsonData
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else { return }
            do {
                let bus = try JSONDecoder().decode(BusResponse.self, from: data)
                buses.append(bus.toBus(locations: locations))
                showing.toggle()
            } catch let error {
                print(error)
            }
        }.resume()
    }
}
