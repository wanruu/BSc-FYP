/* MARK: Location Point */

import Foundation
import SwiftUI

struct LocationPoint: View {
    @State var location: Location
    @ObservedObject var locationGetter: LocationGetterModel
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    var body: some View {
        let x = centerX + CGFloat((location.longitude - locationGetter.current.coordinate.longitude)*lgScale*2) * scale + offset.x
        let y = centerY + CGFloat((locationGetter.current.coordinate.latitude - location.latitude)*laScale*2) * scale + offset.y
        Text(location.name_en).position(x: x, y: y)
    }
}
