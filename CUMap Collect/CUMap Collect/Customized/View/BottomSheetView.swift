import SwiftUI

enum BottomSheetHeight {
    case large, medium, small
    
    func toCGFloat() -> CGFloat {
        switch self {
        case .large: return UIScreen.main.bounds.height * 0.9
        case .medium: return UIScreen.main.bounds.height * 0.5
        case .small: return UIScreen.main.bounds.height * 0.2
        }
    }
}

struct BottomSheetView<Content: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @State var curHeight: BottomSheetHeight = .small
    let largeHeight = BottomSheetHeight.large.toCGFloat()
    let mediumHeight = BottomSheetHeight.medium.toCGFloat()
    let smallHeight = BottomSheetHeight.small.toCGFloat()
    
    @Binding var showing: Bool
    let content: Content
    
    init(showing: Binding<Bool>, @ViewBuilder content: () -> Content) {
        self.content = content()
        self._showing = showing
    }
    
    // gesture
    @GestureState var translation: CGFloat = 0 // amount of movement
    var drag: some Gesture {
        DragGesture()
            .updating($translation) { value, state, _ in
                guard curHeight.toCGFloat() - value.translation.height <= largeHeight else {
                    return
                }
                state = value.translation.height
            }
            .onEnded { value in
                let change = -value.translation.height

                switch curHeight {
                case .small:
                    if change > 0 {
                        if change + smallHeight >= mediumHeight * 0.5 + largeHeight * 0.5 {
                            curHeight = .large
                        } else {
                            curHeight = .medium
                        }
                    }
                case .medium:
                    if change > 0 {
                        curHeight = .large
                    } else {
                        curHeight = .small
                    }
                case .large:
                    if change < 0 {
                        if change + largeHeight <= smallHeight * 0.5 + mediumHeight * 0.5 {
                            curHeight = .small
                        } else {
                            curHeight = .medium
                        }
                    }
                }
            }
    }
    
    // indicator
    var indicator: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.secondary)
            .frame(width: 40, height: 3)
            .padding()
    }
    
    var offset: CGFloat {
        if showing {
            return largeHeight - curHeight.toCGFloat() + translation
        } else {
            return largeHeight
        }
    }
    
    // body
    var body: some View {
        let bgColor = colorScheme == .dark ? Color.black : Color.white
        GeometryReader { geometry in
            VStack {
                Spacer()
                VStack(spacing: 0) {
                    indicator
                    content
                        .frame(height: curHeight.toCGFloat() - 43)
                }
                .frame(width: geometry.size.width, height: largeHeight, alignment: .top)
                .background(bgColor)
                .cornerRadius(10)
                .offset(y: offset)
                .animation(.interactiveSpring(), value: showing)
                .animation(.interactiveSpring(), value: translation)
                .shadow(radius: 5)
            }
        }
        .gesture(drag)
        .edgesIgnoringSafeArea(.all)
    }
}
