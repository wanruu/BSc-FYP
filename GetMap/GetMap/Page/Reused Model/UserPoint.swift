/* MARK: User Point */

import Foundation
import SwiftUI

let innerRadius: CGFloat = 8
let timer = Timer.publish(every: 0.08, on: .main, in: .common).autoconnect()

struct UserPoint: View {
    @ObservedObject var locationGetter: LocationGetterModel
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    @State var animationRadius: CGFloat = 8
    @State var up: Bool = true // animationRadius is becoming larger or not

    var body: some View {
        let center = CGPoint(
            x: centerX + CGFloat((locationGetter.current.longitude - centerLg)*lgScale*2) * scale + offset.x,
            y: centerY + CGFloat((centerLa - locationGetter.current.latitude)*laScale*2) * scale + offset.y
        )
        return
            ZStack {
                AnimationCircle(center: center, radius: animationRadius)
                    .fill(Color.blue.opacity(0.2))
                    .onReceive(timer) { _ in
                        if(up) { animationRadius += 0.4 }
                        else { animationRadius -= 0.4 }
                        if(animationRadius > 17) { up = false }
                        else if(animationRadius < 11) { up = true }
                    }
                DirectionTriangle(center: center, heading: locationGetter.heading)
                    .fill(Color.blue)
                OuterCircle(center: center)
                    .fill(Color.white)
                InnerCircle(center: center)
                    .fill(Color.blue)
            }
    }
}

/* blue */
/* inner part of point */
struct InnerCircle: Shape {
    @State var center: CGPoint
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addArc(center: center, radius: innerRadius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
        return p
    }
}

/* translucent blue */
/* the size of it will change from time to time,
 to show location is updating */
struct AnimationCircle: Shape {
    @State var center: CGPoint
    @State var radius: CGFloat
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addArc(center: center, radius: radius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
        return p
    }
}

/* blue */
/* show direction of user */
struct DirectionTriangle: Shape {
    @State var center: CGPoint
    @State var heading: Double
    func path(in rect: CGRect) -> Path {
        var p = Path()

        let p1 = CGPoint(x: center.x + 2.2 * innerRadius * CGFloat(sin(heading * Double.pi / 180)), y: center.y - 2.2 * innerRadius * CGFloat(cos(heading * Double.pi / 180)))

        let p2 = CGPoint(x: center.x + (innerRadius + 2) * CGFloat(sin((heading + 45) * Double.pi / 180)), y: center.y - (innerRadius + 2) * CGFloat(cos((heading + 45) * Double.pi / 180)))
        let p3 = CGPoint(x: center.x + (innerRadius + 2) * CGFloat(sin((heading - 45) * Double.pi / 180)), y: center.y - (innerRadius + 2) * CGFloat(cos((heading - 45) * Double.pi / 180)))
        
        // p.addArc(center: center, radius: innerRadius + 2, startAngle: .degrees(heading - 45), endAngle: .degrees(heading - 135), clockwise: true)
        p.move(to: p2)
        p.addLine(to: p1)
        p.addLine(to: p3)
        
        return p
    }
}

/* outer part of point */
/* white layer between CorePoint and direction */
struct OuterCircle: Shape {
    @State var center: CGPoint
    func path(in rect: CGRect) -> Path {
        var p = Path()
        p.addArc(center: center, radius: innerRadius + 2, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
        return p
    }
}

