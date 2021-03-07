import SwiftUI
import MapKit

// var lineColor: Color = CU_YELLOW

struct NaviMapView: UIViewRepresentable {
    @Binding var startLoc: Location?
    @Binding var endLoc: Location?
    @Binding var selectedPlan: Plan?
    
    // annotation
    @State var startAnt = MKPointAnnotation()
    @State var endAnt = MKPointAnnotation()
    
    func makeUIView (context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        mapView.addAnnotation(startAnt)
        mapView.addAnnotation(endAnt)
        return mapView
    }
    
    func updateUIView (_ mapView: MKMapView, context: Context) {
        if let startLoc = startLoc {
            startAnt.title = startLoc.nameEn
            startAnt.coordinate = CLLocationCoordinate2D(latitude: startLoc.latitude, longitude: startLoc.longitude)
        }
        if let endLoc = endLoc {
            endAnt.title = endLoc.nameEn
            endAnt.coordinate = CLLocationCoordinate2D(latitude: endLoc.latitude, longitude: endLoc.longitude)
            mapView.setRegion(MKCoordinateRegion(center: endAnt.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
        }
        
        // update plan annotation
        mapView.removeOverlays(mapView.overlays)
        if let plan = selectedPlan {
            // by bus
            var busPolylines: [MKPolyline] = []
            for route in plan.routes.filter({ $0.type == .byBus }) {
                let points = route.points.map({ CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude) })
                busPolylines.append(MKPolyline(coordinates: points, count: points.count))
            }
            mapView.addOverlay(MKMultiPolyline(busPolylines))
            
            // on foot
            for route in plan.routes.filter({ $0.type == .onFoot}) {
                mapView.addOverlays(route.points.map({ MKCircle(center: CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude), radius: 8) }))
            }
            
            // set region
            var minLat: Double = .infinity
            var maxLat: Double = -.infinity
            var minLng: Double = .infinity
            var maxLng: Double = -.infinity
            for route in plan.routes {
                for point in route.points {
                    minLat = min(minLat, point.latitude)
                    maxLat = max(maxLat, point.latitude)
                    minLng = min(minLng, point.longitude)
                    maxLng = max(maxLng, point.longitude)
                }
            }
            mapView.setRegion(
                MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLng + maxLng) / 2),
                    span: MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.5, longitudeDelta: (maxLng - minLng) * 1.5)
                ),
                animated: true
            )
        } else {
            if let startLoc = startLoc, let endLoc = endLoc {
                mapView.setRegion(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: (startLoc.latitude + endLoc.latitude) / 2, longitude: (startLoc.longitude + endLoc.longitude) / 2),
                        span: MKCoordinateSpan(latitudeDelta: abs(startLoc.latitude - endLoc.latitude) * 1.5, longitudeDelta: abs(startLoc.longitude - endLoc.longitude) * 1.5)
                    ),
                    animated: true
                )
            } else if let startLoc = startLoc {
                mapView.setRegion(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: startLoc.latitude, longitude: startLoc.longitude),
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    ),
                    animated: true
                )
            } else if let endLoc = endLoc {
                mapView.setRegion(
                    MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: endLoc.latitude, longitude: endLoc.longitude),
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    ),
                    animated: true
                )
            }
        }
    }
    
    func makeCoordinator () -> Coordinator {
        return Coordinator(self)
    }
    
    // delegate
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: NaviMapView
        
        init (_ parent: NaviMapView) {
            self.parent = parent
        }
        
        // render layout
        func mapView (_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            if overlay is MKMultiPolyline {
                let renderer = MKMultiPolylineRenderer(multiPolyline: overlay as! MKMultiPolyline)
                renderer.strokeColor = UIColor(CU_YELLOW.opacity(0.6))
                renderer.lineWidth = 3
                return renderer
            } else if overlay is MKCircle {
                let renderer = MKCircleRenderer(circle: overlay as! MKCircle)
                renderer.fillColor = UIColor(CU_PURPLE)
                return renderer
            }
            return MKOverlayRenderer()
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation as? MKPointAnnotation == parent.startAnt {
                let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "startLoc")
                annotationView.glyphText = "Start"
                return annotationView
            } else if annotation as? MKPointAnnotation == parent.endAnt {
                let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "endLoc")
                annotationView.glyphText = "End"
                return annotationView
            } else if annotation is MKUserLocation {
                let annotationView = MKUserLocationView(annotation: annotation, reuseIdentifier: "user")
                return annotationView
            }
            return nil
        }
    }
}

