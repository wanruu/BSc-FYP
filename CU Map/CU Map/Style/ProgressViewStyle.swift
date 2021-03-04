import SwiftUI

struct LoadingProgressViewStyle: ProgressViewStyle {
    let width = UIScreen.main.bounds.width * 0.8
    func makeBody(configuration: Configuration) -> some View {
        let ratio = configuration.fractionCompleted ?? 0
        return
            configuration.label
            .padding(.horizontal)
            .padding(.vertical, 8)
            .frame(width: width, alignment: .leading)
            .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.secondary, lineWidth: 0.7))
            .background(HStack {
                RoundedRectangle(cornerRadius: 5)
                    .foregroundColor(CU_PALE_YELLOW)
                    .frame(width: CGFloat(ratio) * width)
                Spacer()
            })
    }
}
