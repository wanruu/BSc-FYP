/*
    Map View.
    - Background Map
    - Search Result: plans
    - User Current Location

 */

import Foundation
import SwiftUI
import MapKit

/*
struct MapView: View {
    @Binding var chosenPlan: Plan?
    @ObservedObject var locationGetter: LocationGetterModel
    
    @Binding var lastHeight: CGFloat
    @Binding var height: CGFloat
    
    // gesture
    @State var lastOffset = Offset(x: 0, y: 0)
    @State var offset = Offset(x: 0, y: 0)
    @State var lastScale = initialZoom
    @State var scale = initialZoom
    
    var gesture: some Gesture {
        SimultaneousGesture(
            MagnificationGesture()
                .onChanged { value in
                    var tmpScale = lastScale * value.magnitude
                    if(tmpScale < minZoomOut) {
                        tmpScale = minZoomOut
                    } else if(tmpScale > maxZoomIn) {
                        tmpScale = maxZoomIn
                    }
                    scale = tmpScale
                    offset = lastOffset * tmpScale / lastScale
                }
                .onEnded { _ in
                    lastScale = scale
                    lastOffset = offset
                },
            DragGesture()
                .onChanged{ value in
                    offset.x = lastOffset.x + value.location.x - value.startLocation.x
                    offset.y = lastOffset.y + value.location.y - value.startLocation.y
                }
                .onEnded{ _ in
                    lastOffset = offset
                }
        )
    }
    
    var body: some View {
        ZStack {
            // background map
            Image("cuhk-campus-map")
                .resizable()
                .frame(width: 3200 * scale, height: 3200 * 25 / 20 * scale, alignment: .center)
                .position(x: UIScreen.main.bounds.width / 2 + offset.x, y: UIScreen.main.bounds.height / 2 + offset.y)
            
            chosenPlan != nil ? PlanMapView(plan: $chosenPlan, opacity: 1, offset: $offset, scale: $scale) : nil
            
            // current location
            UserPoint(locationGetter: locationGetter, offset: $offset, scale: $scale)

        }
        .offset(y: lastHeight >= UIScreen.main.bounds.height * 0.4 ? -lastHeight : 0)
        .animation(
            offset == lastOffset && scale == lastScale ?
                Animation.easeInOut(duration: 0.5) : nil
        )
        // gesture
        .gesture(gesture)
    }
}

struct DrawPoint {
    var type: Int
    var x: CGFloat
    var y: CGFloat
}
extension DrawPoint: Identifiable {
    var id: String {
        "\(type)-\(x)-\(y)"
    }
}

// draw a plan
struct PlanMapView: View {
    @Binding var plan: Plan?
    @State var opacity: Double
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    var body: some View {
        // calculate points list to draw, starting point and ending point may not included
        let DIST: CGFloat = (innerRadius * 1.5) * maxZoomIn / scale // min distance between two point
        var points: [DrawPoint] = []
        
        if plan != nil {
            points.append(DrawPoint(type: plan!.routes[0].type, x: CGFloat((plan!.routes[0].points[0].longitude - centerLg) * lgScale * 2), y: CGFloat((centerLa - plan!.routes[0].points[0].latitude) * laScale * 2)))
            
            var distSoFar: CGFloat = 0
            
            for route in plan!.routes {
                for point in route.points {
                    let lastPoint = points.last!
                    let thisPoint = DrawPoint(type: route.type, x: CGFloat((point.longitude - centerLg) * lgScale * 2), y: CGFloat((centerLa - point.latitude) * laScale * 2))
                    
                    let dist = pow((lastPoint.x - thisPoint.x) * (lastPoint.x - thisPoint.x) + (lastPoint.y - thisPoint.y) * (lastPoint.y - thisPoint.y), 0.5)
                    
                    if distSoFar + dist < DIST {
                        distSoFar += dist
                    } else {
                        distSoFar = 0
                        // TODO: change color of point by route type
                        points.append(thisPoint)
                    }
                }
            }
        }

        return
            ForEach(points) { point in
                Circle()
                    .frame(width: innerRadius, height: innerRadius, alignment: .center)
                    .foregroundColor(point.type == 0 ? CUPurple : CUYellow)
                    .overlay(Circle().stroke(Color.black).frame(width: innerRadius+1, height: innerRadius+1, alignment: .center))
                    .position(x: UIScreen.main.bounds.width / 2 + point.x * scale + offset.x, y: UIScreen.main.bounds.height / 2 + point.y * scale + offset.y)
            }
    }
}

*/

/*struct MapView: View {
    @Binding var chosenPlan: Plan?
    @ObservedObject var locationGetter: LocationGetterModel
    
    @Binding var lastHeight: CGFloat
    @Binding var height: CGFloat

    
    @State var region = MKCoordinateRegion (
            center: CLLocationCoordinate2D(latitude: centerLa, longitude: centerLg),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
    )
    
    @State var trackMode: MapUserTrackingMode = .none
    
    var body: some View {
        if chosenPlan == nil {
            Map(coordinateRegion: $region, interactionModes: .all, showsUserLocation: true).ignoresSafeArea(.all)
        }
    }
}*/

var lineColor: Color = CUYellow

struct MapView: UIViewRepresentable {
    @Binding var startLoc: Location?
    @Binding var endLoc: Location?
    @Binding var chosenPlan: Plan?
    
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
        print(startLoc)
        // update start/end annotation
        if startLoc != nil {
            startAnt.title = "Start"
            startAnt.subtitle = startLoc!.name_en
            startAnt.coordinate = CLLocationCoordinate2D(latitude: startLoc!.latitude, longitude: startLoc!.longitude)
            mapView.addAnnotation(startAnt)
        } else {
            mapView.removeAnnotation(startAnt)
        }
        if endLoc != nil {
            endAnt.title = "End"
            endAnt.subtitle = endLoc!.name_en
            endAnt.coordinate = CLLocationCoordinate2D(latitude: endLoc!.latitude, longitude: endLoc!.longitude)
            mapView.addAnnotation(endAnt)
        } else {
            mapView.removeAnnotation(endAnt)
        }
        
        // update plan annotation
        mapView.removeOverlays(mapView.overlays)
        if chosenPlan != nil {
            var busPolylines: [MKPolyline] = []
            var walkPolylines: [MKPolyline] = []
            for route in chosenPlan!.routes {
                var points: [CLLocationCoordinate2D] = []
                for point in route.points {
                    points.append(CLLocationCoordinate2D(latitude: point.latitude, longitude: point.longitude))
                }
                if route.type == 0 { // walk
                    walkPolylines.append(MKPolyline(coordinates: points, count: points.count))
                } else { // bus
                    busPolylines.append(MKPolyline(coordinates: points, count: points.count))
                }
            }
            lineColor = CUPurple
            mapView.addOverlay(MKMultiPolyline(busPolylines))
            lineColor = CUYellow
            mapView.addOverlay(MKMultiPolyline(walkPolylines))
        }
    }
    
    func makeCoordinator () -> Coordinator {
        return Coordinator(self)
    }
    
    // delegate
    class Coordinator: NSObject, MKMapViewDelegate {
        var parent: MapView
        
        init (_ parent: MapView) {
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
