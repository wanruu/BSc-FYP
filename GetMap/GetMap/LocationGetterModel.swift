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

var manager: CLLocationManager = CLLocationManager()

class LocationGetterModel: NSObject, ObservableObject {
    /* current location information */
    @Published var latitude: Double = 0
    @Published var longitude: Double = 0
    @Published var altitude: Double = 0
    /* list of points/locations */
    @Published var paths: [Point] = []
    /* direction of user */
    @Published var heading: Double = 0

    override init() {
        super.init()
        /* delegate */
        manager.delegate = self
        /* the minimum distance (m) a device must move horizontally before an update event is generated */
        manager.distanceFilter = 10;
        /* the accuracy of the location data our app wants to receive */
        manager.desiredAccuracy = 10;
        
        /* only update location when using app */
        // manager.allowsBackgroundLocationUpdates = true
        // manager.requestWhenInUseAuthorization()
        
        /* always update location */
        manager.requestAlwaysAuthorization()
        
        /* authorization check */
        /* see if needed later*/
        //if(manager.authorizationStatus.rawValue == 0) {
        //    print("No authorization")
        //} else {
        //    print("Authorization OK")
        //}
        
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
        guard let location = locations.last else { return }
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        altitude = location.altitude
        let p = Point(latitude: latitude, longitude: longitude, altitude: altitude)
        if(paths.count == 0 || p != paths[paths.count - 1]) {
            paths.append(p)
        }
    }
    /* successfully update heading */
    internal func locationManager(_ manager: CLLocationManager, didUpdateHeading heading: CLHeading) {
        self.heading = heading.trueHeading
        print(heading.trueHeading)
    }
    /* fail */
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
}
