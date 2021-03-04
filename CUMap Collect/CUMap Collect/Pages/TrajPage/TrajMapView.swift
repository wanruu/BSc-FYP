import SwiftUI
import MapKit

struct TrajMapView: UIViewRepresentable {
    @Binding var isRecording: Bool
    @ObservedObject var locationModel: LocationModel

    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setUserTrackingMode(.followWithHeading, animated: true)
        mapView.showsUserLocation = true

        return mapView
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        if !isRecording {
            mapView.removeOverlays(mapView.overlays)
        } else {
            var polylines: [MKPolyline] = []
            for traj in locationModel.trajs {
                var points: [CLLocationCoordinate2D] = []
                for point in traj {
                    points.append(CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude))
                }
                polylines.append(MKPolyline(coordinates: points, count: points.count))
            }
            let multiPolyline = MKMultiPolyline(polylines)
            mapView.addOverlay(multiPolyline)
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: TrajMapView
        init(_ parent: TrajMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, didUpdate userLocation: MKUserLocation) {
            mapView.setUserTrackingMode(.followWithHeading, animated: true)
        }
        
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            let renderer = MKMultiPolylineRenderer(overlay: overlay)
            renderer.strokeColor = UIColor(CU_PURPLE)
            renderer.lineWidth = 4
            return renderer
        }
    }
}
