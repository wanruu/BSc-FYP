//
//  PathViewModel.swift
//  GetMap
//
//  Created by wanruuu on 29/10/2020.
//

import Foundation
import SwiftUI

struct StraightPath: View {
    @State var pathUnit: PathUnit
    @ObservedObject var locationGetter: LocationGetterModel
    @Binding var offset: CGPoint
    @Binding var scale: CGFloat
    
    var body: some View {
        Path { path in
            guard pathUnit.start_point.count == 3 else {
                print(pathUnit.start_point)
                return }
            guard pathUnit.end_point.count == 3 else {
                print(pathUnit.end_point)
                return }
            let p1 = CGPoint(
                x: centerX + CGFloat((pathUnit.start_point[1] - locationGetter.current.coordinate.longitude)*85390*2) * scale + offset.x,
                y: centerY + CGFloat((locationGetter.current.coordinate.latitude - pathUnit.start_point[0])*111000*2) * scale + offset.y
            )
            let p2 = CGPoint(
                x: centerX + CGFloat((pathUnit.end_point[1] - locationGetter.current.coordinate.longitude)*85390*2) * scale + offset.x,
                y: centerY + CGFloat((locationGetter.current.coordinate.latitude - pathUnit.end_point[0])*111000*2) * scale + offset.y
            )
            path.move(to: p1)
            path.addLine(to: p2)
        }.stroke(Color.black, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
    }
}
