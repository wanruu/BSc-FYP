import SwiftUI
import MapKit

struct RouteMapView: UIViewRepresentable {
    @Binding var route: Route?

    @State var startAnt = MKPointAnnotation()
    @State var endAnt = MKPointAnnotation()

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        startAnt.title = "Start"
        endAnt.title = "End"
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        if route != nil {
            startAnt.coordinate = CLLocationCoordinate2D(latitude: route!.startLoc.latitude, longitude: route!.startLoc.longitude)
            endAnt.coordinate = CLLocationCoordinate2D(latitude: route!.endLoc.latitude, longitude: route!.endLoc.longitude)
            mapView.addAnnotation(startAnt)
            mapView.addAnnotation(endAnt)
            
            var minLat: Double = .infinity
            var maxLat: Double = -.infinity
            var minLng: Double = .infinity
            var maxLng: Double = -.infinity
            
            for point in route!.points {
                minLat = min(minLat, point.latitude)
                maxLat = max(maxLat, point.latitude)
                minLng = min(minLng, point.longitude)
                maxLng = max(maxLng, point.longitude)
            }
            
            let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLng + maxLng) / 2)
            let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.5, longitudeDelta: (maxLng - minLng) * 1.5)
            mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
            
            var coordinates: [CLLocationCoordinate2D] = []
            for point in route!.points {
                coordinates.append(CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude))
            }
            let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
            mapView.removeOverlays(mapView.overlays)
            mapView.addOverlay(polyline)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: RouteMapView
        init(_ parent: RouteMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "")
            annotationView.canShowCallout = false
            return annotationView
        }
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor(CU_PURPLE)
            renderer.lineWidth = 4
            return renderer
        }
    }
}
