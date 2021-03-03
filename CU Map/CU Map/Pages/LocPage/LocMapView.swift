import SwiftUI
import MapKit

struct LocMapView: UIViewRepresentable {
    @State var locations: [Location]
    @Binding var selectedLoc: Location?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setRegion(CENTER_REGION, animated: true)
        mapView.showsUserLocation = true
        
        for loc in locations {
            let ant = MKPointAnnotation()
            ant.coordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
            ant.title = loc.nameEn
            ant.subtitle = loc.type.toString()
            mapView.addAnnotation(ant)
        }

        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        if selectedLoc == nil {
            mapView.deselectAnnotation(mapView.selectedAnnotations.first, animated: true)
        } else {
            let ant = mapView.annotations.first(where: { $0.title == selectedLoc!.nameEn && $0.subtitle == selectedLoc!.type.toString() })
            if ant != nil {
                mapView.setCenter(ant!.coordinate, animated: true)
                mapView.selectAnnotation(ant!, animated: true)
            }
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: LocMapView
        init(_ parent: LocMapView) {
            self.parent = parent
        }
        
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            if annotation is MKPointAnnotation {
                let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: nil)
                annotationView.glyphImage = (annotation.subtitle ?? "Building")?.toLocationType().toUIImage()
                return annotationView
            } else if annotation is MKUserLocation {
                return MKUserLocationView(annotation: annotation, reuseIdentifier: nil)
            }
            return nil
        }
    }
}

