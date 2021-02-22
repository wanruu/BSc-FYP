//
//  LocSearchPage.swift
//  CUMap
//
//  Created by wanruuu on 22/2/2021.
//

import Foundation
import SwiftUI
import MapKit

struct LocSearchPage: View {
    @State var locations: [Location]
    @State var routes: [Route]
    @State var buses: [Bus]
    @State var chosenLoc: Location? = nil
    @State var chosenBus: Bus? = nil
    @State var showBusList: Bool = false
    @State var showList: Bool = false
    @State var showRouteSearchPage: Bool = false
    
    @StateObject var locationGetter = LocationGetterModel()
    
    @State var searchFor: Int = 0 // 0: location, 1: bus
    
    var body: some View {
        NavigationView {
            ZStack {
                LocMapView(locations: locations, routes: routes, chosenLoc: $chosenLoc, chosenBus: $chosenBus).ignoresSafeArea(.all, edges: .top)
                VStack(spacing: 0) {
                    HStack {
                        searchFor == 0 ? NavigationLink(destination: LocListPage(placeholder: "Search for location", keyword: chosenLoc == nil ? "" : chosenLoc!.name_en, locations: locations, showCurrent: false, location: $chosenLoc, showing: $showList), isActive: $showList) {
                            Text(chosenLoc == nil ? "Search for location" : chosenLoc!.name_en)
                                .foregroundColor(chosenLoc == nil ? .gray : .black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } : nil
                        searchFor == 1 ? NavigationLink(destination: BusListPage(placeholder: "Search for bus", keyword: chosenBus == nil ? "": chosenBus!.id, buses: buses, bus: $chosenBus, showing: $showBusList), isActive: $showBusList) {
                            Text(chosenBus == nil ? "Search for bus" : chosenBus!.id)
                                .foregroundColor(chosenBus == nil ? .gray : .black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        } : nil
                        searchFor == 0 && chosenLoc != nil ? Image(systemName: "xmark").imageScale(.large).onTapGesture { chosenLoc = nil } : nil
                        searchFor == 1 && chosenBus != nil ? Image(systemName: "xmark").imageScale(.large).onTapGesture { chosenBus = nil } : nil
                    }
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray, lineWidth: 0.8))
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding()
                    
                    Spacer()
                    Divider()
                    if chosenLoc != nil {
                        VStack(alignment: .leading) {
                            Text(chosenLoc!.name_en).font(.headline)
                            Text(chosenLoc!.type == 1 ? "Bus stop" : "Building")
                            HStack {
                                NavigationLink(destination: RouteSearchPage(locations: locations, routes: routes, buses: buses, startLoc: Location(_id: UUID().uuidString, name_en: "Your Location", latitude: locationGetter.current.latitude, longitude: locationGetter.current.longitude, altitude: locationGetter.current.altitude, type: 0), endLoc: chosenLoc, current: $locationGetter.current, showing: $showRouteSearchPage), isActive: $showRouteSearchPage) {
                                    Text("Directions")
                                }
                                // TODO: implement or delete it
                                NavigationLink(destination: Text("Destination")) {
                                    Text("Save")
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading).padding().background(Color.white)
                    } else {
                        HStack {
                            Button(action: {
                                chosenBus = nil
                                searchFor = 0
                            }) {
                                VStack {
                                    Image(systemName: "building.2")
                                    Text("Location")
                                }.foregroundColor(searchFor == 0 ? .blue : .gray)
                            }
                            Spacer()
                            Button(action: {
                                chosenLoc = nil
                                searchFor = 1
                            }) {
                                VStack {
                                    Image(systemName: "bus")
                                    Text("Bus")
                                }.foregroundColor(searchFor == 1 ? .blue : .gray)
                            }
                            Spacer()
                            
                            NavigationLink(destination: RouteSearchPage(locations: locations, routes: routes, buses: buses, startLoc: Location(_id: UUID().uuidString, name_en: "Your Location", latitude: locationGetter.current.latitude, longitude: locationGetter.current.longitude, altitude: locationGetter.current.altitude, type: 0), endLoc: nil, current: $locationGetter.current, showing: $showRouteSearchPage), isActive: $showRouteSearchPage) {
                                VStack {
                                    Image(systemName: "arrow.triangle.turn.up.right.diamond")
                                    Text("Navigation")
                                }.foregroundColor(.gray)
                            }
                            
                            Spacer()
                            Button(action: {
                                // TODO
                            }) {
                                VStack {
                                    Image(systemName: "heart")
                                    Text("Saved")
                                }.foregroundColor(.gray)
                            }
                        }
                        .padding(.horizontal)
                        .frame(maxWidth: .infinity).padding(.top).background(Color.white)
                    }
                }
            }
            .navigationBarHidden(true)
        }
    }
}

var LocOrBus: Int = 0 // 0: loc, 1: bus
var chosenLocType: Int = 0 // 0: building, 1: bus stop
struct LocMapView: UIViewRepresentable {
    @State var locations: [Location]
    @State var routes: [Route]
    @Binding var chosenLoc: Location?
    @Binding var chosenBus: Bus?
    
    func makeUIView (context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        return mapView
    }
    
    func updateUIView (_ mapView: MKMapView, context: Context) {
        mapView.removeAnnotations(mapView.annotations) // remove all
        mapView.removeOverlays(mapView.overlays)
        if chosenBus != nil {
            var stopList: [Location] = []

            // add annotation
            LocOrBus = 1
            for stopId in chosenBus!.stops {
                let loc = locations.first(where: {$0._id == stopId})!
                stopList.append(loc)
                let locPinAnt = MKPointAnnotation()
                locPinAnt.coordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
                locPinAnt.title = loc.name_en
                mapView.addAnnotation(locPinAnt)
            }
            // add overlay
            var points: [MKMapPoint] = []
            for i in 0..<stopList.count-1 {
                let route1 = routes.first(where: {$0.startLoc == stopList[i] && $0.endLoc == stopList[i+1]})
                let route2 = routes.first(where: {$0.endLoc == stopList[i] && $0.startLoc == stopList[i+1]})
                if route1 != nil {
                    for point in route1!.points {
                        points.append(MKMapPoint(CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)))
                    }
                } else if route2 != nil {
                    for j in route2!.points.count-1...0 {
                        let point = route2!.points[j]
                        points.append(MKMapPoint(CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude)))
                    }
                }
            }
            let polyline = MKPolyline(points: points, count: points.count)
            mapView.addOverlay(polyline)
            
            // set region
            var minLat = INF, maxLat = -INF, minLng = INF, maxLng = -INF
            for stop in stopList {
                minLat = min(minLat, stop.latitude)
                maxLat = max(maxLat, stop.latitude)
                minLng = min(minLng, stop.longitude)
                maxLng = max(maxLng, stop.longitude)
            }
            mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLng + maxLng) / 2), span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.5, longitudeDelta: (maxLng - minLng) * 1.5)), animated: true)
        }

        if chosenLoc != nil {
            // add annotation
            LocOrBus = 0
            chosenLocType = chosenLoc!.type
            let locAnt = MKPointAnnotation()
            locAnt.coordinate = CLLocationCoordinate2D(latitude: chosenLoc!.latitude, longitude: chosenLoc!.longitude)
            locAnt.title = chosenLoc!.name_en
            mapView.addAnnotation(locAnt)
            // set region
            mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: chosenLoc!.latitude, longitude: chosenLoc!.longitude), span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)), animated: true)
        }

    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: LocMapView
        init (_ parent: LocMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKPointAnnotation {
                if LocOrBus == 0 {
                    let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "marker")
                    annotationView.glyphImage = UIImage(systemName: chosenLocType == 0 ? "building.2" : "bus")
                    return annotationView
                } else {
                    let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "pin")
                    return annotationView
                }
            } else if annotation is MKUserLocationView {
                return MKUserLocationView(annotation: annotation, reuseIdentifier: "user")
            }
            return MKAnnotationView(annotation: annotation, reuseIdentifier: "common")
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor(CUPurple)
            renderer.lineWidth = 3
            return renderer
        }
    }
}
