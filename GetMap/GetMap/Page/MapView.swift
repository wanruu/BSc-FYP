/* MARK: display map */

import Foundation
import SwiftUI

// MARK: - overall map, containning raw trajectories, processed path, user location, locations, user path
struct MapView: View {
    @Binding var locations: [Location]
    @Binding var trajectories: [[Coor3D]]
    @Binding var lineSegments: [LineSeg]
    @Binding var representatives: [[Coor3D]]
    @Binding var p: [[Coor3D]]
    @Binding var mapSys: [PathBtwn]
    @ObservedObject var locationGetter: LocationGetterModel
    
    @Binding var showCurrentLocation: Bool
    @Binding var showLocations: Bool
    @Binding var showTrajs: Bool
    @Binding var showLineSegs: Bool
    @Binding var showRepresents: Bool
    @Binding var showMap: Bool
    
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    var body: some View {
        ZStack(alignment: .bottom) {
            showMap ? Image("cuhk-campus-map")
                .resizable()
                .frame(width: 3200 * scale, height: 3200 * 25 / 20 * scale, alignment: .center)
                .position(x: centerX + offset.x, y: centerY + offset.y) : nil
            UserPathsView(locationGetter: locationGetter, offset: $offset, scale: $scale) // user paths
            showTrajs ? TrajsView(trajectories: $trajectories, color: Color.gray, offset: $offset, scale: $scale) : nil // raw trajectories
            showLineSegs ? LineSegsView(lineSegments: $lineSegments, offset: $offset, scale: $scale) : nil
            showRepresents ? TrajsView(trajectories: $representatives, color: Color.black, offset: $offset, scale: $scale) : nil // representative path
            showCurrentLocation ? UserPoint(locationGetter: locationGetter, offset: $offset, scale: $scale) : nil // user location
            showLocations ? LocationsView(locations: $locations, offset: $offset, scale: $scale) : nil // locations
            
            TrajsView(trajectories: $p, color: Color.blue, offset: $offset, scale: $scale)
        }
    }
}

// MARK: - display raw trajectories
struct TrajView: View {
    @Binding var trajectory: [Coor3D]
    @State var color: Color
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    var body: some View {
        Path { p in
            for i in 0..<trajectory.count {
                let point = CGPoint(
                    x: centerX + CGFloat((trajectory[i].longitude - centerLg)*lgScale*2) * scale + offset.x,
                    y: centerY + CGFloat((centerLa - trajectory[i].latitude)*laScale*2) * scale + offset.y
                )
                if(i == 0) {
                    p.move(to: point)
                } else {
                    p.addLine(to: point)
                }
            }
        }.stroke(color, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
    }
}
struct TrajsView: View {
    @Binding var trajectories: [[Coor3D]]
    @State var color: Color
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    var body: some View {
        Path { p in
            for i in 0..<trajectories.count {
                for j in 0..<trajectories[i].count {
                    let point = CGPoint(
                        x: centerX + CGFloat((trajectories[i][j].longitude - centerLg)*lgScale*2) * scale + offset.x,
                        y: centerY + CGFloat((centerLa - trajectories[i][j].latitude)*laScale*2) * scale + offset.y
                    )
                    if(j == 0) {
                        p.move(to: point)
                    } else {
                        p.addLine(to: point)
                    }
                }
            }
        }.stroke(color, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
    }
}
struct LineSegView: View {
    @State var lineSeg: LineSeg
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    var body: some View {
        Path { p in
            let start = CGPoint(
                x: centerX + CGFloat((lineSeg.start.longitude - centerLg)*lgScale*2) * scale + offset.x,
                y: centerY + CGFloat((centerLa - lineSeg.start.latitude)*laScale*2) * scale + offset.y
            )
            let end = CGPoint(
                x: centerX + CGFloat((lineSeg.end.longitude - centerLg)*lgScale*2) * scale + offset.x,
                y: centerY + CGFloat((centerLa - lineSeg.end.latitude)*laScale*2) * scale + offset.y
            )
            p.move(to: start)
            p.addLine(to: end)
        }.stroke(colors[lineSeg.clusterId % colors.count], style: StrokeStyle(lineWidth: 3, lineJoin: .round))
    }
}

struct LineSegsView: View {
    @Binding var lineSegments: [LineSeg]
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    var body: some View {
        ForEach(lineSegments) { lineSeg in
            lineSeg.clusterId >= 0 ? LineSegView(lineSeg: lineSeg, offset: $offset, scale: $scale) : nil
        }
    }
}

// MARK: - display locations
struct LocationsView: View {
    @Binding var locations: [Location]
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    var body: some View {
        ForEach(locations) { location in
            let x = centerX + CGFloat((location.longitude - centerLg)*lgScale*2) * scale + offset.x
            let y = centerY + CGFloat((centerLa - location.latitude)*laScale*2) * scale + offset.y
            Text(location.name_en).position(x: x, y: y)
        }
    }
}

// MARK: - display user path
struct UserPathsView: View {
    @ObservedObject var locationGetter: LocationGetterModel
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    var body: some View {
        Path { p in
            /* draw paths of point list */
            for path in locationGetter.paths {
                for location in path {
                    let point = CGPoint(
                        x: centerX + CGFloat((location.coordinate.longitude - centerLg)*lgScale*2) * scale + offset.x,
                        y: centerY + CGFloat((centerLa - location.coordinate.latitude)*laScale*2) * scale + offset.y
                    )
                    if(location == path[0]) {
                        p.move(to: point)
                    } else {
                        p.addLine(to: point)
                    }
                }
            }
        }.stroke(Color.blue, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
    }
}
