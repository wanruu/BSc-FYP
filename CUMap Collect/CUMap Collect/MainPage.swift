import SwiftUI

enum Page {
    case trajectory
    case location
    case bus
}
struct MainPage: View {
    @StateObject var locationModel = LocationModel()
    @State var page: Page = .location
    
    var body: some View {
        NavigationView {
            ZStack {
                switch page {
                case .trajectory: TrajPage(locationModel: locationModel)
                case .location: LocPage(current: $locationModel.current)
                case .bus: BusPage()
                }
            }
            .toolbar {
                ToolbarItemGroup(placement: .bottomBar) {
                    Spacer()
                    VStack {
                        Image(systemName: "point.fill.topleft.down.curvedto.point.fill.bottomright.up")
                            .imageScale(.large)
                        Text(NSLocalizedString("Trajectory", comment: ""))
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    .padding(.top)
                    .frame(width: UIScreen.main.bounds.width * 0.25)
                    .foregroundColor(page == .trajectory ? Color.accentColor : Color.secondary)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        page = .trajectory
                    }
                    
                    Spacer()
                    
                    VStack {
                        Image(systemName: "building.2")
                            .imageScale(.large)
                        Text(NSLocalizedString("Location", comment: ""))
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    .padding(.top)
                    .frame(width: UIScreen.main.bounds.width * 0.25)
                    .foregroundColor(page == .location ? Color.accentColor : Color.secondary)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        page = .location
                    }
                    
                    Spacer()
                    
                    VStack {
                        Image(systemName: "bus")
                            .imageScale(.large)
                        Text(NSLocalizedString("School bus", comment: ""))
                            .font(.system(size: 15, weight: .medium, design: .rounded))
                            .lineLimit(1)
                            .minimumScaleFactor(0.5)
                    }
                    .padding(.top)
                    .frame(width: UIScreen.main.bounds.width * 0.25)
                    .foregroundColor(page == .bus ? Color.accentColor : Color.secondary)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        page = .bus
                    }
                    Spacer()
                }
            }
        }
    }
}
