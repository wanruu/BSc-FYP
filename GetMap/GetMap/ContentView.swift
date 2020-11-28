//
//  ContentView.swift
//  GetMap
//
//  Created by wanruuu on 24/10/2020.
//

import SwiftUI
import CoreData
import Foundation

func formatter(date: Date) -> String {
    let df = DateFormatter()
    df.dateFormat = "yyyy-MM-dd hh:mm:ss"
    return df.string(from: date)
}

struct ContentView: View {
    /* Core data */
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [], animation: .default)
    var rawPaths: FetchedResults<RawPath>
    
    /* from server */
    @State var locations: [Location] = []
    
    /* pathUnits with different cluster id */
    @State var pathUnits: [PathUnit] = []
    @State var representPaths: [[CLLocation]] = []
    
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
    @State var showRawPaths: Bool = false
    @State var showLocations: Bool = false
    @State var showClusters: Bool = true
    @State var showRepresentPaths: Bool = false
    
    var body: some View {
        NavigationView {
            ZStack(alignment: .bottom) {
                /* user paths */
                UserPathsView(locationGetter: locationGetter, offset: $offset, scale: $scale)
                
                /* existing raw path */
                showRawPaths ?
                    ForEach(rawPaths) { rawPath in
                        RawPathView(locations: rawPath.locations, locationGetter: locationGetter, offset: $offset, scale: $scale)
                    } : nil
                
                /* existing path Units: after cluster */
                showClusters ?
                    ForEach(pathUnits) { pathUnit in
                        pathUnit.clusterId == -1 ? nil : ClusteredPathView(pathUnit: pathUnit, locationGetter: locationGetter, offset: $offset, scale: $scale, color: colors[pathUnit.clusterId % colors.count])
                    } : nil
                /* Representative path */
                showRepresentPaths ?
                    RepresentPathsView(representPaths: representPaths, locationGetter: locationGetter, offset: $offset, scale: $scale) : nil
                
                /* current location point */
                showCurrentLocation ?
                    UserPoint(locationGetter: locationGetter, offset: $offset, scale: $scale) : nil
                
                /* location point */
                showLocations ?
                    ForEach(0..<locations.count) { i in
                        LocationPoint(location: locations[i], locationGetter: locationGetter, offset: $offset, scale: $scale)
                    } : nil
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
                LoadingPage(locations: $locations)
            }
            .navigationBarItems(trailing: HStack {
                Button(action: {
                    for rawPath in locationGetter.paths {
                        if(rawPath.count >= 5) {
                            addRawPath(locations: rawPath)
                        }
                    }
                    cleanPaths()
                }) { Text("Upload") }
                Text(" / ")
                Button(action: {
                    cleanPaths()
                }) { Text("Discard") }
                Text(" / ")
                Button(action: {
                    /* clear */
                    pathUnits = []
                    representPaths = []
                    
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
                    var clusterNum = 0
                    for i in 0..<pathUnits.count {
                        pathUnits[i].clusterId = clusters[i]
                        clusterNum = max(clusterNum, clusters[i])
                    }
                    var C = [[PathUnit]](repeating: [], count: clusterNum)
                    for i in 0..<pathUnits.count {
                        if(clusters[i] != -1 && clusters[i] != 0) {
                            C[clusters[i] - 1].append(pathUnits[i])
                        }
                    }
                    /* representative trajectory */
                    for c in C {
                        let represent = generateRepresent(pathUnits: c)
                        if(represent.count >= 2) {
                            representPaths.append(represent)
                        }
                    }
                }) { Text("Process") }
            })
            .sheet(isPresented: $showFunctionSheet) {
                FunctionSheet(locationGetter: locationGetter, locations: locations, rawPaths: rawPaths, showCurrentLocation: $showCurrentLocation, showRawPaths: $showRawPaths, showLocations: $showLocations, showClusters: $showClusters, showRepresentatives: $showRepresentPaths)
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
