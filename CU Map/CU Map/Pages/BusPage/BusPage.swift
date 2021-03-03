//  BusPage -> BusMapView

import SwiftUI

struct BusPage: View {
    @State var locations: [Location]
    @State var buses: [Bus]
    @State var routesByBus: [Route]
    
    var body: some View {
        List {
            ForEach(buses) { bus in
                NavigationLink(destination: BusMapView(bus: bus, routesByBus: routesByBus).ignoresSafeArea(.all)) {
                    // BusListItem
                    HStack {
                        VStack {
                            Text(bus.line).font(.system(size: 45, weight: .semibold, design: .rounded))
                            Text(bus.nameEn).font(.system(size: 15, design: .rounded))
                        }.lineLimit(1).minimumScaleFactor(0.2).frame(width: UIScreen.main.bounds.width * 0.2)
                        VStack(alignment: .leading) {
                            Text(bus.serviceHour.toString())
                            switch bus.serviceDay {
                            case .holiday: Text(NSLocalizedString("Sun & Public holidays", comment: ""))
                            case .teachingDay: Text(NSLocalizedString("Teaching days only", comment: ""))
                            case .ordinaryDay:
                                VStack(alignment: .leading) {
                                    Text(NSLocalizedString("Mon - Sat", comment: ""))
                                    Text("* " + NSLocalizedString("Service suspended on Public Holidays", comment: "")).font(.footnote).italic().foregroundColor(.gray)
                                }
                            }
                            Text(NSLocalizedString("Departs hourly at (mins)", comment: "") + ": " + bus.departTime.description).lineLimit(2)
                        }
                    }
                    // End of BusListItem
                }.disabled(bus.stops.isEmpty)
            }
        }
        .listStyle(PlainListStyle())
        .navigationBarTitle(NSLocalizedString("School bus", comment: ""))
    }
}

