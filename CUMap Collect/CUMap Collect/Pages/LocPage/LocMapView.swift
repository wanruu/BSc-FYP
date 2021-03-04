import SwiftUI
import MapKit

var locType: LocationType = .building

struct LocMapView: UIViewRepresentable {
    @Binding var locations: [Location]
    @Binding var selectedLoc: Location?
    
    func makeUIView(context: Context) -> MKMapView {
        let mapView = MKMapView()
        mapView.delegate = context.coordinator
        mapView.setUserTrackingMode(.follow, animated: true)
        mapView.showsUserLocation = true
        
        
        mapView.setRegion(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: CENTER_LAT, longitude: CENTER_LNG), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.018)), animated: true)
        return mapView
    }
    
    func updateUIView(_ mapView: MKMapView, context: Context) {
        mapView.removeAnnotations(mapView.annotations)
        for loc in locations {
            let ant = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
            ant.coordinate = coordinate
            ant.title = loc.nameEn
            ant.subtitle = loc.type.toString()
            
            mapView.addAnnotation(ant)
            if loc.id == selectedLoc?.id {
                mapView.deselectAnnotation(mapView.selectedAnnotations.first, animated: true)
                mapView.selectAnnotation(ant, animated: true)
                mapView.setRegion(MKCoordinateRegion(center: coordinate, span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)), animated: true)
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
            if annotation is MKUserLocation {
                return MKAnnotationView(annotation: annotation, reuseIdentifier: "")
            } else {
                let locType: LocationType = (annotation.subtitle ?? "building")?.toLocationType() ?? .building
                let annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: "")
                annotationView.glyphImage = locType.toUIImage()
                return annotationView
            }
        }

    }
}

