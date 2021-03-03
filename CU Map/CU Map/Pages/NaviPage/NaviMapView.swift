import SwiftUI
import MapKit

var lineColor: Color = CU_YELLOW

struct NaviMapView: UIViewRepresentable {
    @Binding var startLoc: Location?
    @Binding var endLoc: Location?
    @Binding var selectedPlan: Plan?
    
    @State var trackingMode: MKUserTrackingMode = .follow
    
    // annotation
    @State var startAnt = MKPointAnnotation()
    @State var endAnt = MKPointAnnotation()
    
    func makeUIView (context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.showsUserLocation = true
        return mapView
    }
    
    func updateUIView (_ mapView: MKMapView, context: Context) {
        // update start/end annotation
        if startLoc != nil {
            startAnt.title = "Start"
            startAnt.subtitle = startLoc!.nameEn
            startAnt.coordinate = CLLocationCoordinate2D(latitude: startLoc!.latitude, longitude: startLoc!.longitude)
            mapView.addAnnotation(startAnt)
        } else {
            mapView.removeAnnotation(startAnt)
        }
        if endLoc != nil {
            endAnt.title = "End"
            endAnt.subtitle = endLoc!.nameEn
            endAnt.coordinate = CLLocationCoordinate2D(latitude: endLoc!.latitude, longitude: endLoc!.longitude)
            mapView.addAnnotation(endAnt)
        } else {
            mapView.removeAnnotation(endAnt)
        }
        
        // update plan annotation
        mapView.removeOverlays(mapView.overlays)
        if selectedPlan != nil {
            var busPolylines: [MKPolyline] = []
            var walkPolylines: [MKPolyline] = []
            for route in selectedPlan!.routes {
                var points: [CLLocationCoordinate2D] = []
                for point in route.points {
                    points.append(CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude))
                }
                if route.type == .onFoot { // walk
                    walkPolylines.append(MKPolyline(coordinates: points, count: points.count))
                } else if route.type == .byBus { // bus
                    busPolylines.append(MKPolyline(coordinates: points, count: points.count))
                }
            }
            lineColor = CU_PURPLE
            mapView.addOverlay(MKMultiPolyline(busPolylines))
            lineColor = CU_YELLOW
            mapView.addOverlay(MKMultiPolyline(walkPolylines))
            
            mapView.setRegion(CENTER_REGION, animated: true)
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
                renderer.strokeColor = UIColor(lineColor)
                renderer.lineWidth = 3
                return renderer
            }
            return MKOverlayRenderer()
        }
        
        func mapViewDidFinishLoadingMap (_ mapView: MKMapView) {
            mapView.setUserTrackingMode(.follow, animated: true)
        }
    }
}

