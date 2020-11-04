//
//  ContentView.swift
//  GetMap
//
//  Created by wanruuu on 24/10/2020.
//

import SwiftUI
import CoreData
import Foundation

/* screen info */
let SCWidth = UIScreen.main.bounds.width
let SCHeight = UIScreen.main.bounds.height

/* center */
let centerX = SCWidth/2
let centerY = SCHeight/2 - 100

struct ContentView: View {
    /* Core data */
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Building.name_en, ascending: true)], animation: .default) var buildings: FetchedResults<Building>
    @FetchRequest(sortDescriptors: [], animation: .default) var pathUnits: FetchedResults<PathUnit>
    
    /* location getter */
    @ObservedObject var locationGetter = LocationGetterModel()
    /* gesture */
    @State var lastOffset: CGPoint = CGPoint(x: 0, y: 0)
    @State var offset: CGPoint = CGPoint(x: 0, y: 0)
    @State var lastScale = CGFloat(1.0)
    @State var scale = CGFloat(1.0)
    @GestureState var magnifyBy = CGFloat(1.0)

    @State var showFunctionSheet: Bool = false
    var body: some View {
        NavigationView {
            /* TODO: ZStack necessary? */
            ZStack(alignment: .bottom) {
                /* show user paths */
                Path { p in
                    /* draw paths of point list */
                    for path in locationGetter.paths {
                        for location in path {
                            /* 1m = 2 (of screen) = 1/111000(latitude) = 1/85390(longitude) */
                            let x = centerX + CGFloat((location.coordinate.longitude - locationGetter.current.coordinate.longitude)*85390*2) + offset.x
                            let y = centerY + CGFloat((locationGetter.current.coordinate.latitude - location.coordinate.latitude)*111000*2) + offset.y
                            if(location == path[0]) {
                                p.move(to: CGPoint(x: x, y: y))
                            } else {
                                p.addLine(to: CGPoint(x: x, y: y))
                            }
                        }
                    }
                }.stroke(Color.gray, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
                
                /* show existing paths */
                ForEach(pathUnits) { pathUnit in
                    StraightPath(pathUnit: pathUnit, locationGetter: locationGetter, offset: $offset, scale: $scale)
                }
                /* show current location point */
                UserPoint(offset: $offset, locationGetter: locationGetter, scale: $scale)
                
                /* show building location point */
                ForEach(buildings) { building in
                    BuildingPoint(building: building, locationGetter: locationGetter, offset: $offset, scale: $scale)
                }
                VStack {
                    Divider()
                    Button(action: {
                        showFunctionSheet = true
                    }) {
                        VStack {
                            Text("^^^")
                            Text("Location: (\(locationGetter.current.coordinate.latitude), \(locationGetter.current.coordinate.longitude))")
                            Text("Accuracy: \(locationGetter.current.horizontalAccuracy)")
                        }
                    }
                }
                .contentShape(Rectangle())
            }
            .navigationBarItems(trailing: HStack {
                Button(action: { deletePathUnit(offsets: IndexSet(integer: 0)) }) { Text("Delete first path unit") }
                Text(" / ")
                Button(action: {
                    partition()
                    // cleanPaths()
                }) { Text("Upload")}
                Text(" / ")
                Button(action: {
                    cleanPaths()
                }) { Text("Discard") }
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
                            scale = lastScale * magnifyBy
                            offset.x = lastOffset.x * scale
                            offset.y = lastOffset.y * scale
                        }
                        .onEnded{ _ in
                            lastScale = scale
                            lastOffset = offset
                        },
                    DragGesture()
                        .onChanged{ value in
                            let changeX = scale * (value.location.x - value.startLocation.x)
                            let changeY = scale * (value.location.y - value.startLocation.y)
                            offset.x = lastOffset.x + changeX
                            offset.y = lastOffset.y + changeY
                        }
                        .onEnded{ _ in lastOffset = offset}
                )
            )
        }
    }
    /* process paths, to path unit */
    private func partition() {
        /* for every path in locationGetter.paths, deal with it */
        for path in locationGetter.paths {
            /* characteristic points */
            var cp: [CLLocation] = []
            /* add starting point to cp */
            cp.append(path[0])
            var startIndex = 0
            var length = 1
            while (startIndex + length <= path.count - 1) {
                let currIndex = startIndex + length
                /* cost if regard current point as charateristic point */
                let costPar = MDLPar(path: path, startIndex: startIndex, endIndex: currIndex)
                /* cost if not regard current point as charateristic point */
                let costNotPar = MDLNotPar(path: path, startIndex: startIndex, endIndex: currIndex)
                print(startIndex, currIndex, costPar, costNotPar)
                if(costPar > costNotPar) {
                    /* add previous point to cp */
                    cp.append(path[currIndex - 1])
                    startIndex = currIndex - 1
                    length = 1
                } else {
                    length += 1
                }
            }
            /* add ending point to cp */
            cp.append(path[path.count - 1])
            print(cp)
            
            /* TODO: modify after test */
            /* upload cp to database */
            for i in 0...(cp.count-2) {
                addPathUnit(start: cp[i], end: cp[i+1])
            }
        }
    }
    /* remove all data in locationGetter.paths */
    private func cleanPaths() {
        locationGetter.paths = []
        locationGetter.paths.append([])
        locationGetter.pathCount = 0
        locationGetter.paths[0].append(locationGetter.current)
    }
    /* add a unit path */
    private func addPathUnit(start: CLLocation, end: CLLocation) {
        withAnimation {
            let newPathUnit = PathUnit(context: viewContext)
            /* PathUnit information */
            newPathUnit.start_point = [start.coordinate.latitude, start.coordinate.longitude, start.altitude]
            newPathUnit.end_point = [end.coordinate.latitude, end.coordinate.longitude, end.altitude]
            newPathUnit.distance = start.distance(from: end)
            newPathUnit.slope = end.altitude - start.altitude
            do {
                try viewContext.save()
                print("New Path unit saved.")
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    /* delete unit path */
    private func deletePathUnit(offsets: IndexSet) {
        withAnimation {
            if(pathUnits.count == 0) {
                return
            }
            offsets.map { pathUnits[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
