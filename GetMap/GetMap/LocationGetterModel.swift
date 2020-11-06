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
import CoreData

/* manager for updating location */
var manager: CLLocationManager = CLLocationManager()

class LocationGetterModel: NSObject, ObservableObject {
    /* current location information */
    @Published var current: CLLocation = CLLocation(latitude: 0, longitude: 0)
    /* list of points/locations */
    @Published var paths: [[CLLocation]] = []
    @Published var pathCount: Int = 0
    /* direction of user */
    @Published var heading: Double = 0

    override init() {
        super.init()
        setup()
    }
    func setup() {
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
        /* ensure within index*/
        if(paths.count == pathCount) {
            paths.append([])
        }
        /* update current location */
        current = newLocation
        
        /* if not accurate, don't record it & switch to next empty path */
        if(newLocation.horizontalAccuracy > 20) {
            // if only 1 point in the path, it should be cleared; continue update this path
            if(paths[pathCount].count == 1) {
                paths[pathCount] = []
            }
            // more than 1 point in the path, update next path
            else if(paths[pathCount].count > 1) {
                pathCount += 1
                paths.append([])
            }
        }
        /* if accurate, record it */
        else {
            paths[pathCount].append(newLocation)
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
