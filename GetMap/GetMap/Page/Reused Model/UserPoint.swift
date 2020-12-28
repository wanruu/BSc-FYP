import Foundation
import SwiftUI


let innerRadius: CGFloat = 8
let timer = Timer.publish(every: 0.08, on: .main, in: .common).autoconnect()

struct UserPoint: View {
    @ObservedObject var locationGetter: LocationGetterModel
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    
    @State var animationRadius: CGFloat = innerRadius
    @State var up: Bool = true // animationRadius is becoming larger or not

    var body: some View {
        
        // center
        let x = centerX + CGFloat((locationGetter.current.longitude - centerLg) * lgScale * 2) * scale + offset.x
        let y = centerY + CGFloat((centerLa - locationGetter.current.latitude) * laScale * 2) * scale + offset.y

        return
            ZStack {
                // animation
                Path { p in
                    p.addArc(center: CGPoint(x: x, y: y), radius: animationRadius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
                }
                    .fill(Color.blue.opacity(0.2))
                    .onReceive(timer) { _ in
                        if(up) { animationRadius += 0.4 }
                        else { animationRadius -= 0.4 }
                        if(animationRadius > innerRadius + 8) { up = false }
                        else if(animationRadius < innerRadius + 3) { up = true }
                    }
                
                // triangle
                Path { p in
                    let p1 = CGPoint(
                        x: x + 2.2 * innerRadius * CGFloat(sin(locationGetter.heading * Double.pi / 180)),
                        y: y - 2.2 * innerRadius * CGFloat(cos(locationGetter.heading * Double.pi / 180)))
                    let p2 = CGPoint(
                        x: x + (innerRadius + 2) * CGFloat(sin((locationGetter.heading + 45) * Double.pi / 180)),
                        y: y - (innerRadius + 2) * CGFloat(cos((locationGetter.heading + 45) * Double.pi / 180)))
                    let p3 = CGPoint(
                        x: x + (innerRadius + 2) * CGFloat(sin((locationGetter.heading - 45) * Double.pi / 180)),
                        y: y - (innerRadius + 2) * CGFloat(cos((locationGetter.heading - 45) * Double.pi / 180)))
                    p.move(to: p2)
                    p.addLine(to: p1)
                    p.addLine(to: p3)
                }.fill(Color.blue)
                
                // outer white
                Path { p in
                    p.addArc(center: CGPoint(x: x, y: y), radius: innerRadius + 2, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
                }.fill(Color.white)
                
                // inner blue
                Path { p in
                    p.addArc(center: CGPoint(x: x, y: y), radius: innerRadius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
                }.fill(Color.blue)
            }
    }
}
