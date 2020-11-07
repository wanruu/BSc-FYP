//
//  ContentView.swift
//  GetMap
//
//  Created by wanruuu on 24/10/2020.
//

import SwiftUI
import CoreData
import Foundation

let colors = [Color.blue, Color.yellow, Color.green, Color.purple, Color.pink, Color.orange, Color.red]

struct Offset {
    var x: CGFloat
    var y: CGFloat
}
extension Offset {
    static func * (offset: Offset, para: CGFloat) -> Offset {
        return Offset(x: offset.x * para, y: offset.y * para)
    }
    static func / (offset: Offset, para: CGFloat) -> Offset {
        return Offset(x: offset.x / para, y: offset.y / para)
    }
}
struct ContentView: View {
    /* Core data */
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Building.name_en, ascending: true)], animation: .default) var buildings: FetchedResults<Building>
    // @FetchRequest(sortDescriptors: [], animation: .default) var pathUnits: FetchedResults<PathUnit>
    @FetchRequest(sortDescriptors: [], animation: .default) var rawPaths: FetchedResults<RawPath>
    
    @State var pathUnits: [PathUnit] = []
    
    /* location getter */
    @ObservedObject var locationGetter = LocationGetterModel()
    /* gesture */
    @State var lastOffset = Offset(x: 0, y: 0)
    @State var offset = Offset(x: 0, y: 0)
    @State var lastScale = CGFloat(1.0)
    @State var scale = CGFloat(1.0)
    @GestureState var magnifyBy = CGFloat(1.0)
    /* setting */
    @State var showFunctionSheet: Bool = false
    @State var showCurrentLocation: Bool = true
    @State var showRawPaths: Bool = true
    @State var showBuildings: Bool = false
    
    var body: some View {
        NavigationView {
            /* TODO: ZStack necessary? */
            ZStack(alignment: .bottom) {
                /* user paths */
                UserPath(locationGetter: locationGetter, offset: $offset, scale: $scale)
                
                /* existing raw path */
                showRawPaths ?
                ForEach(rawPaths) { rawPath in
                    PathView(rawPath: rawPath, locationGetter: locationGetter, offset: $offset, scale: $scale, color: Color.gray)
                } : nil
                
                /* FOR TEST: existing path Units: after cluster */
                ForEach(pathUnits) { pathUnit in
                    pathUnit.clusterId == -1 ? nil :
                    StraightPath(pathUnit: pathUnit, locationGetter: locationGetter, offset: $offset, scale: $scale, color: colors[pathUnit.clusterId % colors.count])
                }
                
                /* current location point */
                showCurrentLocation ?
                    UserPoint(locationGetter: locationGetter, offset: $offset, scale: $scale) : nil
                
                /* building location point */
                showBuildings ?
                ForEach(buildings) { building in
                    BuildingPoint(building: building, locationGetter: locationGetter, offset: $offset, scale: $scale)
                } : nil
                
                Text("+").position(x: centerX, y: centerY)
                
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
                    /* partition */
                    for rawPath in rawPaths {
                        let cp = partition(path: rawPath.locations)
                        for index in 0...cp.count-2 {
                            let newPathUnit = PathUnit(context: viewContext)
                            newPathUnit.start_point = cp[index]
                            newPathUnit.end_point = cp[index+1]
                            pathUnits.append(newPathUnit)
                        }
                    }
                    /* cluster */
                    let clusters = cluster(pathUnits: pathUnits)
                    for i in 0..<clusters.count {
                        pathUnits[i].clusterId = clusters[i]
                    }
                }) { Text("Process") }
            })
            .sheet(isPresented: $showFunctionSheet) {
                FunctionSheet(locationGetter: locationGetter, buildings: buildings, showCurrentLocation: $showCurrentLocation, showRawPaths: $showRawPaths, showBuildings: $showBuildings)
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
                            // offset.x = lastOffset.x * tmpScale / lastScale
                            // offset.y = lastOffset.y * tmpScale / lastScale
                            offset = lastOffset * tmpScale / lastScale
                        }
                        .onEnded{ _ in
                            lastScale = scale
                            lastOffset.x = offset.x
                            lastOffset.y = offset.y
                        },
                    DragGesture()
                        .onChanged{ value in
                            offset.x = lastOffset.x + value.location.x - value.startLocation.x
                            offset.y = lastOffset.y + value.location.y - value.startLocation.y
                        }
                        .onEnded{ _ in
                            lastOffset.x = offset.x
                            lastOffset.y = offset.y
                        }
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
