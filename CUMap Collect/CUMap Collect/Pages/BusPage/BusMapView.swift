import SwiftUI
import MapKit

struct BusMapView: UIViewRepresentable {
    @State var bus: Bus
    @Binding var routes: [Route]

    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator

        var minLat: Double = .infinity
        var maxLat: Double = -.infinity
        var minLng: Double = .infinity
        var maxLng: Double = -.infinity
        
        for stop in bus.stops {
            minLat = min(minLat, stop.latitude)
            maxLat = max(maxLat, stop.latitude)
            minLng = min(minLng, stop.longitude)
            maxLng = max(maxLng, stop.longitude)
            let pointAnt = MKPointAnnotation()
            pointAnt.coordinate = CLLocationCoordinate2D(latitude: stop.latitude, longitude: stop.longitude)
            pointAnt.title = stop.nameEn
            mapView.addAnnotation(pointAnt)
        }
        
        let center = CLLocationCoordinate2D(latitude: (minLat + maxLat) / 2, longitude: (minLng + maxLng) / 2)
        let span = MKCoordinateSpan(latitudeDelta: (maxLat - minLat) * 1.5, longitudeDelta: (maxLng - minLng) * 1.5)
        mapView.setRegion(MKCoordinateRegion(center: center, span: span), animated: true)
        
        var coordinates: [CLLocationCoordinate2D] = []
        for i in 0..<bus.stops.count-1 {
            let startLoc = bus.stops[i]
            let endLoc = bus.stops[i+1]
            let route = routes.first(where: { $0.startLoc.id == startLoc.id && $0.endLoc.id == endLoc.id && $0.type == RouteType.byBus })
            for point in route?.points ?? [] {
                coordinates.append(CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude))
            }
        }
        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline)
        
        return mapView
    }
    
    
    func updateUIView(_ mapView: MKMapView, context: Context) { }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: BusMapView
        init(_ parent: BusMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            let annotationView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "")
            annotationView.canShowCallout = true
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
