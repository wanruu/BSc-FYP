
import Foundation
import SwiftUI

// display raw trajectories
struct TrajView: View {
    @Binding var trajectory: Trajectory
    @State var color: Color
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    var body: some View {
        Path { p in
            for i in 0..<trajectory.points.count {
                let point = CGPoint(
                    x: centerX + CGFloat((trajectory.points[i].longitude - centerLg)*lgScale*2) * scale + offset.x,
                    y: centerY + CGFloat((centerLa - trajectory.points[i].latitude)*laScale*2) * scale + offset.y
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
    @Binding var trajectories: [Trajectory]
    @State var color: Color
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    var body: some View {
        Path { p in
            for i in 0..<trajectories.count {
                for j in 0..<trajectories[i].points.count {
                    let point = CGPoint(
                        x: centerX + CGFloat((trajectories[i].points[j].longitude - centerLg)*lgScale*2) * scale + offset.x,
                        y: centerY + CGFloat((centerLa - trajectories[i].points[j].latitude)*laScale*2) * scale + offset.y
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

// display representative
/*struct RepresentsView: View {
    @Binding var trajs: [[Coor3D]]
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    var body: some View {
        Path { p in
            for i in 0..<trajs.count {
                for j in 0..<trajs[i].count {
                    let point = CGPoint(
                        x: centerX + CGFloat((trajs[i][j].longitude - centerLg) * lgScale * 2) * scale + offset.x,
                        y: centerY + CGFloat((centerLa - trajs[i][j].latitude) * laScale * 2) * scale + offset.y
                    )
                    if j == 0 {
                        p.move(to: point)
                    } else {
                        p.addLine(to: point)
                    }
                }
            }
        }.stroke(Color.black, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
    }
}*/

// colored
struct RepresentsView: View {
    @Binding var trajs: [[Coor3D]]
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    var body: some View {
        ForEach(trajs, id: \.self) { traj in
            let i = trajs.firstIndex(of: traj)!
            Text("\(i)").position(x: centerX + CGFloat((traj[0].longitude - centerLg) * lgScale * 2) * scale + offset.x, y: centerY + CGFloat((centerLa - traj[0].latitude) * laScale * 2) * scale + offset.y)
            Path { p in
                for j in 0..<traj.count {
                    let point = CGPoint(
                        x: centerX + CGFloat((traj[j].longitude - centerLg) * lgScale * 2) * scale + offset.x,
                        y: centerY + CGFloat((centerLa - traj[j].latitude) * laScale * 2) * scale + offset.y
                    )
                    if j == 0 {
                        p.move(to: point)
                    } else {
                        p.addLine(to: point)
                    }
                }
            }.stroke(colors[i % colors.count].opacity(0.5), style: StrokeStyle(lineWidth: 3, lineJoin: .round))
        }
        
    }
}


// display line segments
struct LineSegsView: View {
    @Binding var lineSegments: [LineSeg]
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    var body: some View {
        ForEach(lineSegments) { lineSeg in
            if lineSeg.clusterId >= 0 {
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
    }
}

// display user path
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
