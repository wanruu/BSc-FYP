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
