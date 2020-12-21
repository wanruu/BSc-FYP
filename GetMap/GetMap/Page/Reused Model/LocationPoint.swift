import Foundation
import SwiftUI

struct LocationsView: View {
    @Binding var locations: [Location]
    @Binding var showedLocation: Location?
    
    @Binding var offset: Offset
    @Binding var scale: CGFloat

    var body: some View {
        ZStack {
            ForEach(locations) { location in
                LocationView(location: location, showedLocation: $showedLocation, offset: $offset, scale: $scale)
            }
            showedLocation != nil ?
                Text(showedLocation!.name_en)
                .padding(SCWidth * 0.01)
                .background(Color.white.opacity(0.8))
                .cornerRadius(5)
                .position(
                    x: centerX + CGFloat((showedLocation!.longitude - centerLg)*lgScale*2) * scale + offset.x,
                    y: centerY + CGFloat((centerLa - showedLocation!.latitude)*laScale*2) * scale + offset.y
                ) : nil
        }
    }
}

struct LocationView: View {
    @State var location: Location
    @Binding var showedLocation: Location?
    
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    var body: some View {
        Button(action: {
            if(showedLocation == location) {
                showedLocation = nil
            } else {
                showedLocation = location
            }
        }) {
            location == showedLocation ?
            Image("location-white")
                .resizable()
                .frame(width: SCWidth * 0.1, height: SCWidth * 0.1, alignment: .center) :
            Image(location.type == 0 ? "location-purple" : "location-yellow")
                .resizable()
                .frame(width: SCWidth * 0.1, height: SCWidth * 0.1, alignment: .center)
            
        }
        .position(
            x: centerX + CGFloat((location.longitude - centerLg)*lgScale*2) * scale + offset.x,
            y: centerY + CGFloat((centerLa - location.latitude)*laScale*2) * scale + offset.y - SCWidth * 0.05
        )
    }
}
