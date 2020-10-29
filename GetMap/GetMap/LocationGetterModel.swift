//
//  LocationGetterModel.swift
//  GetMap
//
//  Created by wanruuu on 26/10/2020.
//

/* This is a model for getting location information of user,
 including current latitude, longitude, altitude, heading and a list of location points*/
import Foundation
import CoreLocation

/* manager for updating location */
var manager: CLLocationManager = CLLocationManager()

class LocationGetterModel: NSObject, ObservableObject {
    /* current location information */
    @Published var current: CLLocation = CLLocation(latitude: 0, longitude: 0)
    /* list of points/locations */
    @Published var paths: [CLLocation] = []
    /* direction of user */
    @Published var heading: Double = 0

    override init() {
        super.init()
        /* delegate */
        manager.delegate = self
        /* the minimum distance (m) a device must move horizontally before an update event is generated */
        manager.distanceFilter = 3;
        /* the accuracy of the location data our app wants to receive */
        manager.desiredAccuracy = kCLLocationAccuracyBest;
        
        /* always update location */
        manager.requestAlwaysAuthorization()
        if #available(iOS 9.0, *) {
            manager.allowsBackgroundLocationUpdates = true
        }
        
        /* start updating location */
        manager.startUpdatingLocation()
        /* start updating heading */
        /* TODO: need to verify whether heading information is available */
        manager.startUpdatingHeading()
    }
}

extension LocationGetterModel: CLLocationManagerDelegate {
    /* successfully update location */
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        /* ensure able to get location info */
        guard let newLocation = locations.last else { return }
        current = newLocation
        /* only append to current if location changes */
        if(paths.count == 0) {
            paths.append(current)
        } else {
            let lastLocation = paths[paths.count - 1]
            if(lastLocation.coordinate.latitude != newLocation.coordinate.latitude && lastLocation.coordinate.longitude != newLocation.coordinate.longitude) {
                paths.append(current)
            }
        }
    }
    /* successfully update heading */
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        self.heading = newHeading.trueHeading
    }
    /* fail */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
