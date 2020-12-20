import Foundation
import SwiftUI

struct LocationsView: View {
    @Binding var locations: [Location]
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    var body: some View {
        ForEach(locations) { location in
            LocationView(location: location, offset: $offset, scale: $scale)
        }
    }
}

struct LocationView: View {
    @State var location: Location
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    @State var showText = false
    var body: some View {
        let x = centerX + CGFloat((location.longitude - centerLg)*lgScale*2) * scale + offset.x
        let y = centerY + CGFloat((centerLa - location.latitude)*laScale*2) * scale + offset.y
        Button(action: {
            showText = !showText
        }) {
            Image(location.type == 0 ? "location-purple" : "location-yellow")
            .resizable()
            .frame(width: SCWidth * 0.1, height: SCWidth * 0.1, alignment: .center)
            
        }.position(x: x, y: y)
        showText ? Text(location.name_en).position(x: x, y: y - SCWidth * 0.05) : nil
    }
}
