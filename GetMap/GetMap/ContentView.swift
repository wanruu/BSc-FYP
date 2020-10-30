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
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Building.name_en, ascending: true)],
        animation: .default)
    var buildings: FetchedResults<Building>
    
    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    var pathUnits: FetchedResults<PathUnit>
    
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
                /* recording user paths */
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
                // Button(action: { addPathUnit() }) { Text("Add Path Unit") }
                // Button(action: { deletePathUnit(offsets: IndexSet(integer: 0)) }) { Text("Delete first path unit") }
                Button(action: { uploadPath() }) { Text("Upload")}
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
                        }
                        .onEnded{ _ in
                            lastScale = scale
                        },
                    DragGesture()
                        .onChanged{ value in
                            let changeX = value.location.x - value.startLocation.x
                            let changeY = value.location.y - value.startLocation.y
                            offset.x = lastOffset.x + changeX
                            offset.y = lastOffset.y + changeY
                        }
                        .onEnded{ _ in lastOffset = offset}
                )
            )
        }
    }
    private func uploadPath() {
        /* test data */
        locationGetter.paths = [[
            CLLocation(latitude: 0, longitude: 0),
            CLLocation(latitude: 0.00002, longitude: 0.00008),
            CLLocation(latitude: 0.00001, longitude: 0.00013),
            CLLocation(latitude: -0.00002, longitude: 0.00016),
            CLLocation(latitude: 0, longitude: 0.00026),
        ]]
        print(CLLocation(latitude: 0, longitude: 0).distance(from: CLLocation(latitude: 0.0002, longitude: 0.0008)))
        print(locationGetter.paths)
        partition()
        // cleanPaths()
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
        }
        
    }
    private func MDLPar(path: [CLLocation], startIndex: Int, endIndex: Int) -> Double {
        /* only two cp in this trajectory */
        /* distance between two charateristic points */
        var angleSum = 0.0
        var perpSum = 0.0
        let x1: Double = path[startIndex].coordinate.latitude
        let y1: Double = path[startIndex].coordinate.longitude
        let x2: Double = path[endIndex].coordinate.latitude
        let y2: Double = path[endIndex].coordinate.longitude
        let diffX: Double = x1 - x2
        let diffY: Double = y1 - y2

        for index in startIndex...(endIndex - 1) {
            /* line: (x1 - x2)(y - y1) - (y1 - y2)*(x - x1) = 0 */
            let xi = path[index].coordinate.latitude
            let yi = path[index].coordinate.longitude
            let xii = path[index + 1].coordinate.latitude
            let yii = path[index + 1].coordinate.longitude
            /* perpendicular distance */
            let tmp = pow(diffX*diffX+diffY*diffY, 0.5)
            let pd1 = abs(diffX*(yi-y1)-diffY*(xi-x1)) / tmp
            let pd2 = abs(diffX*(yii-y1)-diffY*(xii-x1)) / tmp
            perpSum += (pd1*pd1+pd2*pd2)/(pd1+pd2)
            /* angle distance */
            angleSum += abs(pd2 - pd1)
        }
        let LH: Double = log2(pow(diffX*diffX+diffY*diffY, 0.5))
        let LH_D = log2(angleSum) + log2(perpSum)
        return LH + LH_D
    }
    private func MDLNotPar(path: [CLLocation], startIndex: Int, endIndex: Int) -> Double {
        var LH: Double = 0
        // LH_D = 0 under this situation
        for index in startIndex...(endIndex - 1) {
            let diffX: Double = path[index].coordinate.latitude - path[index+1].coordinate.latitude
            let diffY: Double = path[index].coordinate.longitude - path[index+1].coordinate.longitude
            LH += log2(pow(diffX*diffX+diffY*diffY, 0.5))
        }
        return LH
    }
    /* remove all data in locationGetter.paths */
    private func cleanPaths() {
        locationGetter.paths = []
        locationGetter.pathCount = 0
        locationGetter.paths[0].append(locationGetter.current)
    }
    /* add a unit path */
    private func addPathUnit() {
        withAnimation {
            let newPathUnit = PathUnit(context: viewContext)
            /* PathUnit information */
            newPathUnit.start_point = [37, -122, 0]
            newPathUnit.end_point = [38, -122, 2]
            newPathUnit.distance = 0
            newPathUnit.slope = 0
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
