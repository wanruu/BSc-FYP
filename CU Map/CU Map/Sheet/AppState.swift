

import Foundation

struct AppState {
    var mainPage = MainPage()
    var locPage = LocPage()
    var pcPage = PCPage()
}


extension AppState{
    
    struct MainPage {
        var locations: [Location] = []
        var buses: [Bus] = []
        var routesOnFoot: [Route] = []
        var routesByBus: [Route] = []
    }
    
    
    struct LocPage {
        var savedLocs: [String] = []{
            didSet{
                UserDefaults.standard.set(savedLocs, forKey: "savedLocs")
            }
        }
    }
    
    struct PCPage {
        var savedBuses: [Bus] = []
        var savedLocs: [Location] = []
    }
    
    
}
