import Foundation
import SwiftUI

struct MyButtonStyle: ButtonStyle {
    var bgColor: Color
    
    var disabled: Bool
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding()
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
