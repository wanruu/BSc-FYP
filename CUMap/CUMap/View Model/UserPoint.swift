import Foundation
import SwiftUI


let innerRadius: CGFloat = 8
let timer = Timer.publish(every: 0.08, on: .main, in: .common).autoconnect()

struct UserPoint: View {
    @ObservedObject var locationGetter: LocationGetterModel
    @Binding var offset: Offset
    @Binding var scale: CGFloat
    @Binding var height: CGFloat
    
    @State var animationRadius: CGFloat = 8
    @State var up: Bool = true // animationRadius is becoming larger or not

    var body: some View {
        let center = CGPoint(
            x: centerX + CGFloat((locationGetter.current.longitude - centerLg) * lgScale * 2) * scale + offset.x,
            y: centerY + CGFloat((centerLa - locationGetter.current.latitude) * laScale * 2) * scale + offset.y - height + smallH)

        return
            ZStack {
                // animation
                Path { p in
                    p.addArc(center: center, radius: animationRadius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
                }
                    .fill(Color.blue.opacity(0.2))
                    .onReceive(timer) { _ in
                        if(up) { animationRadius += 0.4 }
                        else { animationRadius -= 0.4 }
                        if(animationRadius > 17) { up = false }
                        else if(animationRadius < 11) { up = true }
                    }
                
                // triangle
                Path { p in
                    let p1 = CGPoint(
                        x: center.x + 2.2 * innerRadius * CGFloat(sin(locationGetter.heading * Double.pi / 180)),
                        y: center.y - 2.2 * innerRadius * CGFloat(cos(locationGetter.heading * Double.pi / 180)))
                    let p2 = CGPoint(
                        x: center.x + (innerRadius + 2) * CGFloat(sin((locationGetter.heading + 45) * Double.pi / 180)),
                        y: center.y - (innerRadius + 2) * CGFloat(cos((locationGetter.heading + 45) * Double.pi / 180)))
                    let p3 = CGPoint(
                        x: center.x + (innerRadius + 2) * CGFloat(sin((locationGetter.heading - 45) * Double.pi / 180)),
                        y: center.y - (innerRadius + 2) * CGFloat(cos((locationGetter.heading - 45) * Double.pi / 180)))
                    p.move(to: p2)
                    p.addLine(to: p1)
                    p.addLine(to: p3)
                }.fill(Color.blue)
                
                // outer white
                Path { p in
                    p.addArc(center: center, radius: innerRadius + 2, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
                }.fill(Color.white)
                
                // inner blue
                Path { p in
                    p.addArc(center: center, radius: innerRadius, startAngle: .degrees(0), endAngle: .degrees(360), clockwise: true)
                }.fill(Color.blue)
            }
    }
}
