import Foundation
import SwiftUI

struct ZoomOutStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.8 : 1)
            .animation(.spring())
    }
}

struct MyButtonStyle: ButtonStyle {
    var bgColor: Color
    
    var disabled: Bool
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .background(
                disabled ?
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.gray.opacity(0.8))
                    .animation(.spring()) :
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(bgColor.opacity(configuration.isPressed ? 0.8 : 0.2))
                    .animation(.spring())
                
            )
            .scaleEffect(configuration.isPressed ? 0.95: 1)
            .foregroundColor(.primary)
            .animation(.spring())
    }
    
}

// press: white -> bgColor
struct MyButtonStyle2: ButtonStyle {
    var bgColor: Color
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .background(
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(bgColor.opacity(configuration.isPressed ? 0.7 : 0))
                    .animation(.spring())
            )
            .scaleEffect(configuration.isPressed ? 0.95: 1)
            .foregroundColor(.primary)
            .animation(.spring())
    }
}

// press: white -> bgColor, size doesn't change
struct MyButtonStyle3: ButtonStyle {
    var bgColor: Color
    
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .background(
                Rectangle()
                    .fill(bgColor.opacity(configuration.isPressed ? 1 : 0))
                    .animation(.spring())
            )
            .foregroundColor(.primary)
    }
}
