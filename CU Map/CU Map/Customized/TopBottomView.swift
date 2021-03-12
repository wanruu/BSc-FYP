import SwiftUI

struct TopBottomView<Top: View, Bottom: View>: View {
    @Environment(\.colorScheme) var colorScheme
    @State var curHeight: BottomSheetHeight = .small
    let largeHeight = BottomSheetHeight.large.toCGFloat()
    let mediumHeight = BottomSheetHeight.medium.toCGFloat()
    let smallHeight = BottomSheetHeight.small.toCGFloat()
    
    @Binding var showBottom: Bool
    let top: Top
    let bottom: Bottom
    
    init(showBottom: Binding<Bool>, @ViewBuilder top: () -> Top, @ViewBuilder bottom: () -> Bottom) {
        self.top = top()
        self.bottom = bottom()
        self._showBottom = showBottom
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
    
    // bottom offset
    var bottomOffset: CGFloat {
        if showBottom {
            return largeHeight - curHeight.toCGFloat() + translation
        } else {
            return largeHeight
        }
    }
    
    var topOffset: CGFloat {
        if !showBottom || curHeight == .small {
            return 0
        } else {
            return -curHeight.toCGFloat()
        }
    }
    
    // indicator
    var indicator: some View {
        RoundedRectangle(cornerRadius: 10)
            .fill(Color.secondary)
            .frame(width: 40, height: 3)
            .padding(20)
    }
    
    // body
    var body: some View {
        let bgColor = colorScheme == .dark ? Color.black : Color.white
        ZStack {
            GeometryReader { geometry in
                top
                    .frame(width: geometry.size.width)
                    .padding(.top, geometry.safeAreaInsets.top)
                    .background(bgColor)
                    .clipped()
                    .shadow(radius: 5)
                    .offset(y: -geometry.safeAreaInsets.top + topOffset)
                    .animation(Animation.easeIn(duration: 0.5), value: translation)
            }
            GeometryReader { geometry in
                VStack {
                    Spacer()
                    VStack(spacing: 0) {
                        indicator
                        bottom
                            .frame(height: curHeight.toCGFloat() - 43)
                    }
                    .frame(width: geometry.size.width, height: largeHeight, alignment: .top)
                    .background(bgColor)
                    .cornerRadius(10)
                    .offset(y: bottomOffset)
                    .animation(.interactiveSpring(), value: showBottom)
                    .animation(.interactiveSpring(), value: translation)
                    .shadow(radius: 5)
                }
            }
            .gesture(drag)
            .edgesIgnoringSafeArea(.bottom)
        }
    }
}
