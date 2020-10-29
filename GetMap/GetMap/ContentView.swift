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
    
    /* add building function */
    @State var buildingName: String = ""

    @State var showBuildingList: Bool = false
    
    var body: some View {
        print(pathUnits)
        return NavigationView {
            /* TODO: ZStack necessary? */
            ZStack(alignment: .bottomLeading) {
                /* recording user paths */
                /* Path { path in
                    /* draw paths of point list */
                    for location in locationGetter.paths {
                        /* 1m = 2 (of screen) = 1/111000(latitude) = 1/85390(longitude) */
                        let x = centerX + CGFloat((location.coordinate.longitude - locationGetter.current.coordinate.longitude)*85390*2) + offset.x
                        let y = centerY + CGFloat((locationGetter.current.coordinate.latitude - location.coordinate.latitude)*111000*2) + offset.y
                        if(location == locationGetter.paths[0]) {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }.stroke(Color.gray, style: StrokeStyle(lineWidth: 3, lineJoin: .round))*/
                
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
                    Text("(\(locationGetter.current.coordinate.latitude), \(locationGetter.current.coordinate.longitude))")
                    HStack {
                        TextField( "Name of the building", text: $buildingName).textFieldStyle(RoundedBorderTextFieldStyle())
                        Button(action: {
                            guard buildingName != "" else { return }
                            addBuilding()
                            buildingName = ""
                        } ){ Text("Add") }.padding()
                    }.padding()
                }
            }
            .navigationBarItems(trailing: VStack {
                Button(action: { showBuildingList = true }) { Text("Buildings") }
                Button(action: { addPathUnit() }) { Text("Add Path Unit") }
                Button(action: { deletePathUnit(offsets: IndexSet(integer: 0)) }) { Text("Delete first path unit") }
            })
            .sheet(isPresented: $showBuildingList) {
                BuildingListSheet(buildings: buildings)
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
                print("New Path saved.")
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
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
    /* add current location to building list */
    private func addBuilding() {
        withAnimation {
            let newBuilding = Building(context: viewContext)
            /* building information */
            newBuilding.timestamp = Date()
            newBuilding.name_en = buildingName
            newBuilding.latitude = locationGetter.current.coordinate.latitude
            newBuilding.longitude = locationGetter.current.coordinate.longitude
            do {
                try viewContext.save()
                print("New Building saved.")
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
    /* TODO: modify it */
    private func deleteBuildings(offsets: IndexSet) {
        withAnimation {
            offsets.map { buildings[$0] }.forEach(viewContext.delete)
            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
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
