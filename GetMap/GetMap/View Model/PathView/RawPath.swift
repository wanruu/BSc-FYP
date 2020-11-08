/* MARK: draw raw path */

/* Input: [CLLocation]
   Output: Gray lines
 */

import Foundation
import SwiftUI
import CoreLocation

struct RawPathView: View {
    @State var locations: [CLLocation]
    @ObservedObject var locationGetter: LocationGetterModel
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    var body: some View {
        Path { p in
            for location in locations {
                let point = CGPoint(
                    x: centerX + CGFloat((location.coordinate.longitude - locationGetter.current.coordinate.longitude)*lgScale*2) * scale + offset.x,
                    y: centerY + CGFloat((locationGetter.current.coordinate.latitude - location.coordinate.latitude)*laScale*2) * scale + offset.y
                )
                if(location == locations[0]) {
                    p.move(to: point)
                } else {
                    p.addLine(to: point)
                }
            }
        }.stroke(Color.gray, style: StrokeStyle(lineWidth: 3, lineJoin: .round))
    }
}




