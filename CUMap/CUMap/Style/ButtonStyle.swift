import Foundation
import SwiftUI

struct MyButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.gray.opacity(configuration.isPressed ? 0.2 : 0))
                    .animation(.spring())
            )
            .scaleEffect(configuration.isPressed ? 0.95: 1)
            .foregroundColor(.primary)
            .animation(.spring())
    }
}

// white -> bgColor
struct MyButtonStyle2: ButtonStyle {
    @State var bgColor: Color
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .background(bgColor.opacity(configuration.isPressed ? 1 : 0))
            .animation(.spring())
    }
}
