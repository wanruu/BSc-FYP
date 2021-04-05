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
    @Binding var curHeight: BottomSheetHeight
    let largeHeight = BottomSheetHeight.large.toCGFloat()
    let mediumHeight = BottomSheetHeight.medium.toCGFloat()
    let smallHeight = BottomSheetHeight.small.toCGFloat()
    
    @Binding var showing: Bool
    
    var heightChanged: (BottomSheetHeight) -> Void
    
    let content: Content
    
    init(showing: Binding<Bool>, height: Binding<BottomSheetHeight>, heightChanged: @escaping (BottomSheetHeight) -> Void, @ViewBuilder content: () -> Content) {
        self._curHeight = height
        self.content = content()
        self._showing = showing
        
        self.heightChanged = { height in
            withAnimation {
                heightChanged(height)
            }
        }
            
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
                            heightChanged(curHeight)
                        } else {
                            curHeight = .medium
                            heightChanged(curHeight)
                        }
                    }
                case .medium:
                    if change > 0 {
                        curHeight = .large
                        heightChanged(curHeight)
                    } else {
                        curHeight = .small
                        heightChanged(curHeight)
                    }
                case .large:
                    if change < 0 {
                        if change + largeHeight <= smallHeight * 0.5 + mediumHeight * 0.5 {
                            curHeight = .small
                            heightChanged(curHeight)
                        } else {
                            curHeight = .medium
                            heightChanged(curHeight)
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
    
    
    var body: some View {
        ZStack{
            
            if self.showing{
                Color(.systemBackground)
                    .opacity(0.000001)
                    .edgesIgnoringSafeArea(.bottom)
                    .onTapGesture {
                        Store.shared.endEditing()
                        withAnimation {
                            self.showing = false
                        }
                    }
            }
            
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    HStack{
                        indicator
                    }.frame(maxWidth: .infinity)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        Store.shared.endEditing()
                        withAnimation {
                            self.showing = false
                        }
                    }
                    
                    content
                        .frame(height: curHeight.toCGFloat(), alignment: .top)
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .top)
                .background(Color(.systemBackground))
                .cornerRadius(10)
                .offset(y: offset)
                .animation(.interactiveSpring(), value: showing)
                .animation(.interactiveSpring(), value: translation)
                .shadow(radius: 5)
            }.gesture(drag)
            .edgesIgnoringSafeArea(.bottom)
        }.edgesIgnoringSafeArea(.bottom)
       
    }
}



