//
//  PathViewModel.swift
//  GetMap
//
//  Created by wanruuu on 29/10/2020.
//

import Foundation
import SwiftUI

/* draw user path */
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
    }
}
/* draw path unit */
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

/* draw representative path */
