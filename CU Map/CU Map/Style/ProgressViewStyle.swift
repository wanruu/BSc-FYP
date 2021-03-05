import SwiftUI

struct LoadingProgressViewStyle: ProgressViewStyle {
    let imgWidth: CGFloat = 90
    let imgHeight: CGFloat = 30
    
    let width = UIScreen.main.bounds.width * 0.8
    let height = UIScreen.main.bounds.width * 0.05
    
    func makeBody(configuration: Configuration) -> some View {
        let ratio = CGFloat(configuration.fractionCompleted ?? 0)
        return
            VStack {
                Image("cubus")
                    .resizable()
                    .frame(width: imgWidth, height: imgHeight)
                    .offset(x: (width - imgWidth) * (ratio - 0.5))
                
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(CU_PALE_YELLOW)
                    .frame(width: ratio * width, height: height)
                    .frame(width: width, alignment: .leading)
                    .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.secondary, lineWidth: 0.7))
            }
    }
}

