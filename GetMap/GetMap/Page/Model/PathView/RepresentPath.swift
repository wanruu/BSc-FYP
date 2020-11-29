/* MARK: draw representative path */

/* Input: [[CLLocation]] */

import Foundation
import SwiftUI
import CoreLocation

struct RepresentPathsView: View {
    @Binding var representatives: [[Coor3D]]
    @ObservedObject var locationGetter: LocationGetterModel
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    var body: some View {
        Path { p in
            for i in 0..<representatives.count {
                for j in 0..<representatives[i].count {
                    let point = CGPoint(
                        x: centerX + CGFloat((representatives[i][j].longitude - locationGetter.current.coordinate.longitude)*lgScale*2) * scale + offset.x,
                        y: centerY + CGFloat((locationGetter.current.coordinate.latitude - representatives[i][j].latitude)*laScale*2) * scale + offset.y
                    )
                    if(j == 0) {
                        p.move(to: point)
                    } else {
                        p.addLine(to: point)
                    }
                }
            }
        }.stroke(Color.pink.opacity(0.3), style: StrokeStyle(lineWidth: 2, lineJoin: .round))
    }
}
