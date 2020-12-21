/* MARK: MapPage contains MapView + other functions */

import Foundation
import SwiftUI
import CoreLocation

struct MapPage: View {
    @Binding var locations: [Location]
    @Binding var trajectories: [[Coor3D]]

    @Binding var mapSys: [PathBtwn]

    @State var lineSegments: [LineSeg] = []
    @State var representatives: [[Coor3D]] = []
    
    /* sheet */
    @State var showTrajs: Bool = true // trajectories
    @State var showLineSegs: Bool = false // lineSegments
    @State var showRepresents: Bool = false // representatives
    @State var showMap: Bool = true

    @State var showSheet: Bool = false
    
    /* gesture */
    @State var offset = Offset(x: 0, y: 0)
    @State var scale = minZoomOut
    @State var lastOffset = Offset(x: 0, y: 0)
    @State var lastScale = minZoomOut
    
    var body: some View {
        ZStack {
            showMap ? Image("cuhk-campus-map")
                .resizable()
                .frame(width: 3200 * scale, height: 3200 * 25 / 20 * scale, alignment: .center)
                .position(x: centerX + offset.x, y: centerY + offset.y) : nil
            
            // raw trajectories
            showTrajs ? TrajsView(trajectories: $trajectories, color: Color.gray, offset: $offset, scale: $scale) : nil
            
            showLineSegs ? LineSegsView(lineSegments: $lineSegments, offset: $offset, scale: $scale) : nil
            
            // representative path
            showRepresents ? TrajsView(trajectories: $representatives, color: Color.black, offset: $offset, scale: $scale) : nil
        }
        // navigation bar
        .navigationTitle("Map")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarItems(trailing: Button(action: { showSheet = true }) { Image(systemName: "gearshape").imageScale(.large) } )
        // function sheet
        .sheet(isPresented: $showSheet) {
            NavigationView {
                FuncSheet(showTrajs: $showTrajs, showLineSegs: $showLineSegs, showRepresents: $showRepresents, showMap: $showMap, locations: $locations, trajectories: $trajectories, lineSegments: $lineSegments, representatives: $representatives, mapSys: $mapSys)
                .navigationTitle("Setting")
                .navigationBarTitleDisplayMode(.inline)
                .navigationBarItems(trailing: Button(action: {showSheet = false}) { Text("Cancel")})
            }
        }
        // gesture
        .contentShape(Rectangle())
        .gesture(SimultaneousGesture(
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
