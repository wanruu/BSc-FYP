/* printing represent path */

import Foundation
import CoreLocation

func printRepresent(represent: [CLLocation]) {
    if(represent.count <= 1) {
        return
    }
    // print(represent.count)
    var out = "["
    
    for location in represent {
        out = out + "PathPoint(latitude: " + String(location.coordinate.latitude) + ", longitude: " + String(location.coordinate.longitude) + ", altitude: " + String(location.altitude) + ")"
        if(location != represent[represent.count-1]) {
            out = out + ", "
        }
        
    }
    
    print(out + "],")
}
