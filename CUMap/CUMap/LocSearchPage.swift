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
    @State var showList: Bool = false
    @State var showRouteSearchPage: Bool = false
    
    @StateObject var locationGetter = LocationGetterModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                LocMapView(chosenLoc: $chosenLoc).ignoresSafeArea(.all)
                VStack {
                    HStack {
                        NavigationLink(destination: LocListPage(placeholder: "Search", keyword: chosenLoc == nil ? "" : chosenLoc!.name_en, locations: locations, showCurrent: false, location: $chosenLoc, showing: $showList), isActive: $showList) {
                            Text(chosenLoc == nil ? "Search" : chosenLoc!.name_en)
                                .foregroundColor(chosenLoc == nil ? .gray : .black)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        chosenLoc == nil ? nil : Image(systemName: "xmark").imageScale(.large)
                            .onTapGesture { chosenLoc = nil }
                    }
                    .padding()
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray, lineWidth: 0.8))
                    .background(Color.white)
                    .cornerRadius(16)
                    .padding()
                    
                    Spacer()
                    
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
                    }
                    
                }
            }
            .navigationBarHidden(true)
        }
    }
}

struct LocMapView: UIViewRepresentable {
    @Binding var chosenLoc: Location?
    
    // location annotation
    @State var locAnt = MKPointAnnotation()
    
    func makeUIView (context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        return mapView
    }
    
    func updateUIView (_ mapView: MKMapView, context: Context) {
        mapView.removeAnnotation(locAnt)
        if chosenLoc != nil {
            // add annotation
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
    }
}
