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
let centerY = SCHeight/2

struct ContentView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \Building.name_en, ascending: true)],
        animation: .default)
    private var buildings: FetchedResults<Building>
    
    /* location getter */
    @ObservedObject var locationView = LocationGetterModel()
    /* panned offset */
    @State var lastOffset: CGPoint = CGPoint(x: 0, y: 0)
    @State var offset: CGPoint = CGPoint(x: 0, y: 0)
    /* for animation of current location point */
    let timer = Timer.publish(every: 0.08, on: .main, in: .common).autoconnect()
    @State var animationRadius: CGFloat = 8
    @State var up: Bool = true // animationRadius is becoming larger or not
    /* add building function */
    @State var buildingName: String = ""

    var body: some View {
        print(buildings)
        /* user location point: at the center by default; panned with offset */
        let center = CGPoint(x: centerX + offset.x, y: centerY + offset.y)
        /* render */
        return ZStack(alignment: .bottomLeading) {
            GestureControlLayer { pan in
                if(pan.moving) {
                    offset.x = lastOffset.x + pan.offset.x
                    offset.y = lastOffset.y + pan.offset.y
                } else {
                    lastOffset = offset
                }
            }.background(Color.white)
            
            Path { path in
                /* draw paths of point list */
                for location in locationView.paths {
                    /* 1m = 2 (of screen) = 1/111000(latitude) = 1/85390(longitude) */
                    let x = centerX + CGFloat((location.coordinate.longitude - locationView.current.coordinate.longitude)*85390*2) + offset.x
                    let y = centerY + CGFloat((locationView.current.coordinate.latitude - location.coordinate.latitude)*111000*2) + offset.y
                    if(location == locationView.paths[0]) {
                        path.move(to: CGPoint(x: x, y: y))
                    } else {
                        path.addLine(to: CGPoint(x: x, y: y))
                    }
                }
            }.stroke(Color.black, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
            
            /* TODO: Try to capsulate */
            /* showing current location point */
            Animation(center: center, radius: animationRadius)
                .fill(Color.blue.opacity(0.2))
                .onReceive(timer) { _ in
                    if(up) { animationRadius += 0.4 }
                    else { animationRadius -= 0.4 }
                    if(animationRadius > 17) { up = false }
                    else if(animationRadius < 11) { up = true }
                }
            UserDirection(center: center, heading: locationView.heading)
                .fill(Color.blue)
            OuterPoint(center: center)
                .fill(Color.white)
            InnerPoint(center: center)
                .fill(Color.blue)
            /* ******************************* */
            VStack {
                HStack {
                    TextField( "Name of the building", text: $buildingName)
                         .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        guard buildingName != "" else { return }
                        addBuilding()
                        buildingName = ""
                    } ){ Text("Add") }
                        .padding()
                }
                 
            }
                .padding()
        }
    }

    private func addBuilding() {
        withAnimation {
            let newBuilding = Building(context: viewContext)
            /* building information */
            newBuilding.timestamp = Date()
            newBuilding.name_en = buildingName
            newBuilding.latitude = locationView.current.coordinate.latitude
            newBuilding.longitude = locationView.current.coordinate.longitude
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

/* ?? */
private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView().environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
    }
}
