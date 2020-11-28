/* MARK: draw representative path */

/* Input: [[CLLocation]] */

import Foundation
import SwiftUI
import CoreLocation

struct RepresentPathsView: View {
    @State var representPaths: [[CLLocation]]
    @ObservedObject var locationGetter: LocationGetterModel
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    var body: some View {
        Path { p in
            for representPath in representPaths {
                for location in representPath {
                    let point = CGPoint(
                        x: centerX + CGFloat((location.coordinate.longitude - locationGetter.current.coordinate.longitude)*lgScale*2) * scale + offset.x,
                        y: centerY + CGFloat((locationGetter.current.coordinate.latitude - location.coordinate.latitude)*laScale*2) * scale + offset.y
                    )
                    if(location == representPath[0]) {
                        p.move(to: point)
                    } else {
                        p.addLine(to: point)
                    }
                }
            }
        }.stroke(Color.pink.opacity(0.3), style: StrokeStyle(lineWidth: 2, lineJoin: .round))
    }
}
