/* MARK: Building Point */

import Foundation
import SwiftUI

struct BuildingPoint: View {
    @State var building: Building
    @ObservedObject var locationGetter: LocationGetterModel
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    var body: some View {
        let x = centerX + CGFloat((building.longitude - locationGetter.current.coordinate.longitude)*lgScale*2) * scale + offset.x
        let y = centerY + CGFloat((locationGetter.current.coordinate.latitude - building.latitude)*laScale*2) * scale + offset.y
        Text(building.name_en).position(x: x, y: y)
    }
}
