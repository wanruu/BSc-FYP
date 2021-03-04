import SwiftUI

struct RoundedShrinkDarkerButtonStyle: ButtonStyle {
    var bgColor: Color
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(bgColor.opacity(configuration.isPressed ? 1 : 0))
                    .animation(.spring())
            )
            .scaleEffect(configuration.isPressed ? 0.95: 1)
            .animation(.spring())
    }
}

struct NaviButtonStyle: ButtonStyle {
    var fgColor: Color
    var bgColor: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.9 : 1)
            .foregroundColor(fgColor)
            .background(
                RoundedRectangle(cornerRadius: 3)
                    .fill(bgColor.opacity(configuration.isPressed ? 0.6 : 1))
                    .rotationEffect(Angle(degrees: 45))
                    .shadow(radius: 10)
                    .scaleEffect(configuration.isPressed ? 0.9 : 1)
                    .animation(.spring())
            )
            .animation(.spring())
    }
}
