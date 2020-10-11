//
//  MapView.swift
//  CUHKMap
//
//  Created by wanruuu on 11/10/2020.
//

import SwiftUI
import MapKit

struct MapView: UIViewRepresentable {
    // var start: CLLocationCoordinate2D
    @State var start: String
    @State var coor_start: Array<Double>
    @State var dest: String
    @State var coor_dest: Array<Double>
    
    func makeUIView(context: Context) -> MKMapView {
        MKMapView(frame: .zero)
    }
    func updateUIView(_ uiView: MKMapView, context: Context) {

        /* center of the map */
        var center_lati: Double = 22.420021
        var center_long: Double = 114.208190
        /* span */
        var delta_lati: Double = 0.015
        var delta_long: Double = 0.015
        /* annotation for starting point and destination */
        let annotation1 = MKPointAnnotation()
        let annotation2 = MKPointAnnotation()
        annotation1.title = "Starting Point - " + start
        annotation1.coordinate = CLLocationCoordinate2D(latitude: coor_start[0], longitude: coor_start[1])
        annotation2.title = "Destination - " + dest
        annotation2.coordinate = CLLocationCoordinate2D(latitude: coor_dest[0], longitude: coor_dest[1])
        
        if(start != "" && dest != "") {
            uiView.addAnnotations([annotation1, annotation2])
            delta_lati = abs(coor_start[0] - coor_dest[0])
            delta_long = abs(coor_start[1] - coor_dest[1])
            center_lati = (coor_start[0] + coor_dest[0])/2
            center_long = (coor_start[1] + coor_dest[1])/2
        } else if(start != "" && dest == "") {
            center_lati = coor_start[0]
            center_long = coor_start[1]
            uiView.addAnnotation(annotation1)
        } else if(dest != "" && start == "") {
            center_lati = coor_dest[0]
            center_long = coor_dest[1]
            uiView.addAnnotation(annotation2)
        }
        
        let coordinate = CLLocationCoordinate2D (
            latitude: center_lati, longitude: center_long
        )
        let span = MKCoordinateSpan(latitudeDelta: delta_lati, longitudeDelta: delta_long)
        let region = MKCoordinateRegion(center: coordinate, span: span)
        uiView.setRegion(region, animated: true)
    }
}

struct MapView_Previews: PreviewProvider {
    static var previews: some View {
        MapView(start: "", coor_start: [0, 0], dest: "", coor_dest: [0, 0])
    }
}
