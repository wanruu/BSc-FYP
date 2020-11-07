//
//  ContentView.swift
//  GetMap
//
//  Created by wanruuu on 24/10/2020.
//

import SwiftUI
import CoreData
import Foundation

struct ContentView: View {
    /* Core data */
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Building.name_en, ascending: true)], animation: .default) var buildings: FetchedResults<Building>
    // @FetchRequest(sortDescriptors: [], animation: .default) var pathUnits: FetchedResults<PathUnit>
    @FetchRequest(sortDescriptors: [], animation: .default) var rawPaths: FetchedResults<RawPath>
    
    @State var pathUnits: [PathUnit] = []
    
    /* for test neighbor*/
    @State var core: [PathUnit] = []
    
    /* location getter */
    @ObservedObject var locationGetter = LocationGetterModel()
    /* gesture */
    @State var lastOffset: CGPoint = CGPoint(x: 0, y: 0)
    @State var offset: CGPoint = CGPoint(x: 0, y: 0)
    @State var lastScale = CGFloat(1.0)
    @State var scale = CGFloat(1.0)
    @GestureState var magnifyBy = CGFloat(1.0)
    /* setting */
    @State var showFunctionSheet: Bool = false
    var body: some View {
        /* let p1 = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 0, longitude: 0), altitude: 0, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
        let p2 = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 0.00008, longitude: 0.00002), altitude: 0, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
        let p3 = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 0.00013, longitude: 0.00001), altitude: 0, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
        let p4 = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 0.00016, longitude: -0.00002), altitude: 0, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
        let p5 = CLLocation(coordinate: CLLocationCoordinate2D(latitude: 0.00026, longitude: 0), altitude: 0, horizontalAccuracy: 5, verticalAccuracy: 5, timestamp: Date())
        let cp = partition(path: [p1, p2, p3, p4, p5])
        print(cp)
        return */
        NavigationView {
            /* TODO: ZStack necessary? */
            ZStack(alignment: .bottom) {
                /* user paths */
                UserPath(locationGetter: locationGetter, offset: $offset, scale: $scale)
                
                /* existing raw path */
                ForEach(rawPaths) { rawPath in
                    PathView(rawPath: rawPath, locationGetter: locationGetter, offset: $offset, scale: $scale, color: Color.gray)
                }
                
                /* existing path Units */
                ForEach(pathUnits) { pathUnit in
                    StraightPath(pathUnit: pathUnit, locationGetter: locationGetter, offset: $offset, scale: $scale, color: Color.black)
                }
                
                /* neighbor: for test */
                ForEach(core) { c in
                    StraightPath(pathUnit: c, locationGetter: locationGetter, offset: $offset, scale: $scale, color: Color.pink)
                }
                
                
                /* current location point */
                UserPoint(offset: $offset, locationGetter: locationGetter, scale: $scale)
                
                /* building location point */
                ForEach(buildings) { building in
                    BuildingPoint(building: building, locationGetter: locationGetter, offset: $offset, scale: $scale)
                }
                VStack {
                    Divider()
                    Button(action: {
                        showFunctionSheet = true
                    }) {
                        VStack {
                            Text("Location: (\(locationGetter.current.coordinate.latitude), \(locationGetter.current.coordinate.longitude))")
                            Text("Altitude: \(locationGetter.current.altitude)")
                            Text("Accuracy: \(locationGetter.current.horizontalAccuracy)")
                        }
                    }
                }
                .contentShape(Rectangle())
            }
            .navigationBarItems(trailing: HStack {
                Button(action: {
                    for rawPath in locationGetter.paths {
                        if(rawPath.count >= 2) {
                            addRawPath(locations: rawPath)
                        }
                    }
                }) { Text("Upload") }
                Text(" / ")
                Button(action: {
                    cleanPaths()
                }) { Text("Discard") }
                Text(" / ")
                Button(action: {
                    for rawPath in rawPaths {
                        let cp = partition(path: rawPath.locations)
                        for index in 0...cp.count-2 {
                            let newPathUnit = PathUnit(context: viewContext)
                            newPathUnit.start_point = cp[index]
                            newPathUnit.end_point = cp[index+1]
                            pathUnits.append(newPathUnit)
                        }
                    }
                    let nei = neighbor(pathUnits: pathUnits)
                    for i in 0..<nei.count {
                        if(nei[i].count >= MinLns) {
                            core.append(pathUnits[i])
                        }
                    }
                    // print(neighbor(pathUnits: pathUnits))
                    
                }) { Text("Partition") }
            })
            .sheet(isPresented: $showFunctionSheet) {
                FunctionSheet(locationGetter: locationGetter, buildings: buildings)
            }
            .contentShape(Rectangle())
            .gesture(
                SimultaneousGesture(
                    MagnificationGesture()
                        .updating($magnifyBy) { currentState, gestureState, transaction in
                            gestureState = currentState
                            var tmpScale = lastScale * magnifyBy
                            if(tmpScale < minZoomOut) {
                                tmpScale = minZoomOut
                            } else if(tmpScale > maxZoomIn) {
                                tmpScale = maxZoomIn
                            }
                            scale = tmpScale
                            offset.x = lastOffset.x * tmpScale / lastScale
                            offset.y = lastOffset.y * tmpScale / lastScale
                        }
                        .onEnded{ _ in
                            lastScale = scale
                            lastOffset = offset
                        },
                    DragGesture()
                        .onChanged{ value in
                            offset.x = lastOffset.x + value.location.x - value.startLocation.x
                            offset.y = lastOffset.y + value.location.y - value.startLocation.y
                        }
                        .onEnded{ _ in lastOffset = offset }
                )
            )
        }
    }
    
    /* remove all data in locationGetter.paths */
    private func cleanPaths() {
        locationGetter.paths = []
        locationGetter.paths.append([])
        locationGetter.pathCount = 0
        locationGetter.paths[0].append(locationGetter.current)
    }
    
    // MARK: - Core Data function
    private func addPathUnit(start: CLLocation, end: CLLocation) {
        let newPathUnit = PathUnit(context: viewContext)
        /* PathUnit information */
        newPathUnit.start_point = start
        newPathUnit.end_point = end
        do { try viewContext.save() }
        catch { fatalError("Error in addPathUnit.") }
    }
    private func deletePathUnit(offsets: IndexSet) {
        if(pathUnits.count == 0) { return }
        offsets.map { pathUnits[$0] }.forEach(viewContext.delete)
        do { try viewContext.save() }
        catch { fatalError("Error in deletePathUnit.") }
    }
    private func addRawPath(locations: [CLLocation]) {
        let newRawPath = RawPath(context: viewContext)
        newRawPath.locations = locations
        do { try viewContext.save() }
        catch { fatalError("Error in addRawPath.") }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
