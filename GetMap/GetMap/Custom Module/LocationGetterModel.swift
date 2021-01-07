// Model for Collecting User Location Data

/* This is a model for getting location information of user,
 including current latitude, longitude, altitude, heading and a list of location points
 */

import Foundation
import CoreLocation

/* manager for updating location */
var manager: CLLocationManager = CLLocationManager()

class LocationGetterModel: NSObject, ObservableObject {
    // current location information
    @Published var current: Coor3D = Coor3D(latitude: 0, longitude: 0, altitude: 0)
    // user trajectories
    @Published var trajs: [[Coor3D]] = []
    // which index of trajs is being updating
    @Published var trajsIndex: Int = 0
    // user heading
    @Published var heading: Double = 0

    override init() {
        super.init()
        // delegate
        manager.delegate = self
        
        // minimum distance (m) a device must move horizontally before an update event is generated
        manager.distanceFilter = 5;
        
        // accuracy of location data our app wants to receive
        manager.desiredAccuracy = kCLLocationAccuracyBest;
        
        // always update location
        manager.requestAlwaysAuthorization()
        if #available(iOS 9.0, *) {
            manager.allowsBackgroundLocationUpdates = true
        }
        
        // start updating location
        manager.startUpdatingLocation()
        
        // start updating heading
        /* TODO: need to verify whether heading information is available */
        manager.startUpdatingHeading()
    }
}

extension LocationGetterModel: CLLocationManagerDelegate {
    // successfully update location
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        // ensure able to get location info
        guard let lastLocation = locations.last else { return }
        let newLocation = Coor3D(latitude: lastLocation.coordinate.latitude, longitude: lastLocation.coordinate.longitude, altitude: lastLocation.altitude)
        
        // update current location
        current = newLocation
        
        // ensure within index
        if(trajs.count == trajsIndex) {
            trajs.append([])
        }
        
        // if not accurate, don't record it & switch to next empty path
        if(lastLocation.horizontalAccuracy > 20) {
            // if only 1 point in the path, it should be cleared; continue update this path
            if(trajs[trajsIndex].count == 1) {
                trajs[trajsIndex] = []
            }
            // more than 1 point in the path, update next path
            else if(trajs[trajsIndex].count > 1) {
                trajsIndex += 1
            }
        }
        // if accurate, record it
        else {
            trajs[trajsIndex].append(newLocation)
        }
    }
    
    // successfully update heading
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.heading = newHeading.trueHeading
    }
    
    // fail
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}

