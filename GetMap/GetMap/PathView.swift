//
//  PathViewModel.swift
//  GetMap
//
//  Created by wanruuu on 29/10/2020.
//

import Foundation
import SwiftUI

// MARK: - draw raw path : gray
struct PathView: View {
    @State var rawPath: RawPath
    @ObservedObject var locationGetter: LocationGetterModel
    @Binding var offset: CGPoint
    @Binding var scale: CGFloat
    var body: some View {
        Path { p in
            for location in rawPath.locations {
                /* 1m = 2 (of screen) = 1/111000(latitude) = 1/85390(longitude) */
                let point = CGPoint(
                    x: centerX + CGFloat((location.coordinate.longitude - locationGetter.current.coordinate.longitude)*lgScale*2) * scale + offset.x,
                    y: centerY + CGFloat((locationGetter.current.coordinate.latitude - location.coordinate.latitude)*laScale*2) * scale + offset.y
                )
                if(location == rawPath.locations[0]) {
                    p.move(to: point)
                } else {
                    p.addLine(to: point)
                }
            }
        }.stroke(Color.gray, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
    }
}
// MARK: - draw user path : blue
struct UserPath: View {
    @ObservedObject var locationGetter: LocationGetterModel
    @Binding var offset: CGPoint
    @Binding var scale: CGFloat
    var body: some View {
        Path { p in
            /* draw paths of point list */
            for path in locationGetter.paths {
                for location in path {
                    /* 1m = 2 (of screen) = 1/111000(latitude) = 1/85390(longitude) */
                    let point = CGPoint(
                        x: centerX + CGFloat((location.coordinate.longitude - locationGetter.current.coordinate.longitude)*lgScale*2) * scale + offset.x,
                        y: centerY + CGFloat((locationGetter.current.coordinate.latitude - location.coordinate.latitude)*laScale*2) * scale + offset.y
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
// MARK: - draw path unit : black
struct StraightPath: View {
    @State var pathUnit: PathUnit
    @ObservedObject var locationGetter: LocationGetterModel
    @Binding var offset: CGPoint
    @Binding var scale: CGFloat
    
    var body: some View {
        Path { path in
            let p1 = CGPoint(
                x: centerX + CGFloat((pathUnit.start_point.coordinate.longitude - locationGetter.current.coordinate.longitude)*85390*2) * scale + offset.x,
                y: centerY + CGFloat((locationGetter.current.coordinate.latitude - pathUnit.start_point.coordinate.latitude)*111000*2) * scale + offset.y
            )
            let p2 = CGPoint(
                x: centerX + CGFloat((pathUnit.end_point.coordinate.longitude - locationGetter.current.coordinate.longitude)*85390*2) * scale + offset.x,
                y: centerY + CGFloat((locationGetter.current.coordinate.latitude - pathUnit.end_point.coordinate.latitude)*111000*2) * scale + offset.y
            )
            path.move(to: p1)
            path.addLine(to: p2)
        }.stroke(Color.black, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
    }
}

// MARK: - draw representative path