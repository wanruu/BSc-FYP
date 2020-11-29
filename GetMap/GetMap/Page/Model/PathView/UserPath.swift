/* MARK: draw user path */

/* Input: locationGetter.paths [[CLLocation]]
   Output: blue lines
 */

import Foundation
import SwiftUI

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
