import SwiftUI
import MapKit

struct BusListView: View {
    @Binding var locations: [Location]
    @Binding var buses: [Bus]
    @Binding var routes: [Route]

    var body: some View {
        List {
            ForEach(buses) { bus in
                NavigationLink(destination: BusMapView(bus: bus, routes: $routes).ignoresSafeArea(.all)) {
                    // BusListItem
                    HStack {
                        VStack {
                            Text(bus.line).font(.system(size: 45, weight: .semibold, design: .rounded))
                            Text(bus.nameEn).font(.system(size: 15, design: .rounded))
                        }.lineLimit(1).minimumScaleFactor(0.2).frame(width: UIScreen.main.bounds.width * 0.2)
                        VStack(alignment: .leading) {
                            Text(bus.serviceHour.toString())
                            switch bus.serviceDay {
                            case .holiday: Text(NSLocalizedString("Sun & public holidays", comment: ""))
                            case .teachingDay: Text(NSLocalizedString("teaching days only", comment: ""))
                            case .ordinaryDay:
                                VStack(alignment: .leading) {
                                    Text(NSLocalizedString("Mon - Sat", comment: ""))
                                    Text("* " + NSLocalizedString("service suspended on public holidays", comment: "")).font(.footnote).italic().foregroundColor(.gray)
                                }
                            }
                            Text(NSLocalizedString("departs hourly at (mins)", comment: "") + ": " + bus.departTime.description).lineLimit(2)
                        }
                    }
                    // End of BusListItem
                }.disabled(bus.stops.isEmpty)
            }.onDelete { indexSet in
                deleteBus(index: indexSet.first!)
            }
        }.listStyle(PlainListStyle())
    }
    
    private func deleteBus(index: Int) {
        let dataStr = "id=" + buses[index].id
        let url = URL(string: server + "/bus")!
        var request = URLRequest(url: url)
        request.addValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        request.httpMethod = "DELETE"
        request.httpBody = dataStr.data(using: String.Encoding.utf8)
        
        URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            guard let data = data else { return }
            do {
                let res = try JSONDecoder().decode(DeleteResult.self, from: data)
                if(res.deletedCount == 1) {
                    buses.remove(at: index)
                }
            } catch let error {
                print(error)
            }
        }.resume()
    }
}
