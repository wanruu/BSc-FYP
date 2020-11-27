//
//  MainPage.swift
//  CUMap
//
//  Created by wanruuu on 27/11/2020.
//

import Foundation
import SwiftUI
import MapKit

struct MainPage: View {
    @Binding var page: Int
    @Binding var start: String
    @Binding var end: String
    @ObservedObject var locationGetter: LocationGetterModel

    var body: some View {
        VStack {
            TextField("From", text: $start, onEditingChanged: { _ in page = 1 }).textFieldStyle(RoundedBorderTextFieldStyle())
            TextField("To", text: $end, onEditingChanged: { _ in page = 2 }).textFieldStyle(RoundedBorderTextFieldStyle())
            Spacer()
            ZStack {
                // MapView(start: "", coor_start: [0, 0], dest: "", coor_dest: [0, 0])
                PathView(locationGetter: locationGetter, paths: pathData)
            }
        }
    }
}

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

/* draw path in PathData */
struct PathView: View {
    @ObservedObject var locationGetter: LocationGetterModel
    @State var paths: [[PathPoint]]
    
    /* gesture */
    @State var lastOffset = Offset(x: 0, y: 0)
    @State var offset = Offset(x: 0, y: 0)
    @State var lastScale = CGFloat(1.0)
    @State var scale = CGFloat(1.0)
    @GestureState var magnifyBy = CGFloat(1.0)
    
    var body: some View {
        Path { p in
            for path in paths {
                for location in path {
                    let point = CGPoint(
                        x: centerX + CGFloat((location.longitude - locationGetter.current.coordinate.longitude)*lgScale*2) * scale + offset.x,
                        y: centerY + CGFloat((locationGetter.current.coordinate.latitude - location.latitude)*laScale*2) * scale + offset.y
                    )
                    if(location == path[0]) {
                        p.move(to: point)
                    } else {
                        p.addLine(to: point)
                    }
                }
            }
        }
        .stroke(Color.pink.opacity(0.3), style: StrokeStyle(lineWidth: 2, lineJoin: .round))
        //.contentShape(Rectangle())
        .gesture(
            //SimultaneousGesture(
                /*MagnificationGesture()
                    .updating($magnifyBy) { currentState, gestureState, transaction in
                        gestureState = currentState
                        var tmpScale = lastScale * magnifyBy
                        if(tmpScale < minZoomOut) {
                            tmpScale = minZoomOut
                        } else if(tmpScale > maxZoomIn) {
                            tmpScale = maxZoomIn
                        }
                        self.scale = tmpScale
                        self.offset = lastOffset * tmpScale / lastScale
                    }
                    .onEnded{ _ in
                        lastScale = scale
                        lastOffset.x = offset.x
                        lastOffset.y = offset.y
                    },*/
                DragGesture()
                    .onChanged{ value in
                        offset.x = lastOffset.x + value.location.x - value.startLocation.x
                        offset.y = lastOffset.y + value.location.y - value.startLocation.y
                    }
                    .onEnded{ _ in
                        lastOffset.x = offset.x
                        lastOffset.y = offset.y
                    }
            //)
        )
    }
}

struct Offset {
    var x: CGFloat
    var y: CGFloat
}

extension Offset {
    static func * (offset: Offset, para: CGFloat) -> Offset {
        return Offset(x: offset.x * para, y: offset.y * para)
    }
    static func / (offset: Offset, para: CGFloat) -> Offset {
        return Offset(x: offset.x / para, y: offset.y / para)
    }
}
