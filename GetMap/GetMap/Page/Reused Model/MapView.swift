
import Foundation
import SwiftUI

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
            for path in locationGetter.trajs {
                for location in path {
                    let point = CGPoint(
                        x: centerX + CGFloat((location.longitude - centerLg)*lgScale*2) * scale + offset.x,
                        y: centerY + CGFloat((centerLa - location.latitude)*laScale*2) * scale + offset.y
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
