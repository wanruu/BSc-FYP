import Foundation
import SwiftUI

struct BackgroundTurnColorButtonStyle: ButtonStyle {
    var bgColor: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(bgColor.opacity(configuration.isPressed ? 1 : 0).animation(.spring()))
            
    }
}

struct ShrinkButtonStyle: ButtonStyle {
    var bgColor: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(RoundedRectangle(cornerRadius: 10, style: .continuous).fill(bgColor))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .foregroundColor(.primary)
            .animation(.spring())
    }
}

struct ShrinkDarkerButtonStyle: ButtonStyle {
    var bgColor: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(bgColor.opacity(configuration.isPressed ? 1 : 0)).animation(.spring()))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
            .foregroundColor(.primary)
            .animation(.spring())
    }
}

struct ForegroundButtonStyle: ButtonStyle {
    var foreColor: Color
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundColor(foreColor)
    }
}
