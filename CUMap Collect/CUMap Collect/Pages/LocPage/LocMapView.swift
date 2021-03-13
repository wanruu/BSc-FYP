import SwiftUI
import MapKit

struct LocMapView: View {
    @Binding var locations: [Location]
    @Binding var selectedLoc: Location?
    
    @State var region = MKCoordinateRegion(center: CENTER_COOR2D, span: LARGE_SPAN)
    @State var trackingMode: MapUserTrackingMode = .none
    
    let imageLength: CGFloat = 20 // length of annotation image
    let imagePadding: CGFloat = 6 // padding of annotation image
    let textWidth: CGFloat = 100
    
    var body: some View {
        let minLatDiff = (Double)(region.span.latitudeDelta) / (Double)(UIScreen.main.bounds.height) * (Double)(imageLength * 2 + imagePadding * 6)
        let minLnfDiff = (Double)(region.span.longitudeDelta) / (Double)(UIScreen.main.bounds.width) * (Double)(textWidth)
        var locs: [Location] = []
        if let selectedLoc = selectedLoc {
            locs.append(selectedLoc)
        }
        for location in locations {
            var overlapped = false
            for loc in locs {
                if abs(loc.longitude - location.longitude) < minLnfDiff && abs(loc.latitude - location.latitude) < minLatDiff {
                    overlapped = true
                    break
                }
            }
            if !overlapped {
                locs.append(location)
            }
        }
        return Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true, userTrackingMode: $trackingMode, annotationItems: locs) { loc in
            MapAnnotation(coordinate: CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)) {
                ZStack {
                    loc.type.toImage()
                        .resizable()
                        .frame(width: imageLength, height: imageLength)
                        .foregroundColor(Color.white)
                        .padding(imagePadding)
                        .background(Circle().fill(CU_YELLOW).shadow(radius: 5))
                        .onTapGesture {
                            selectedLoc = loc
                        }
                        .scaleEffect(loc.id == selectedLoc?.id ? 1.4 : 1)
                    Text(loc.nameEn)
                        .lineLimit(2)
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .frame(width: textWidth)
                        .offset(y: loc.id == selectedLoc?.id ? 1.4 * (imageLength + imagePadding * 2) : (imageLength + imagePadding * 2))
                }
            }
        }
        .ignoresSafeArea(.all)
        .animation(.easeIn, value: selectedLoc)
        .onChange(of: selectedLoc, perform: { value in
            if let loc = value {
                region = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude), span: SMALL_SPAN)
            }
        })
    }
}

/*
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

*/
