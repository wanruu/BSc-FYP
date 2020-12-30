import Foundation
import SwiftUI


// no padding
struct CheckBox: View {
    @State var options: [String]
    @Binding var checked: Int
    
    @State var spacing: CGFloat
    
    var body: some View {
        VStack(alignment: .leading, spacing: spacing) {
            ForEach(options.indices) { index in
                HStack {
                    Image(systemName: checked == index ? "checkmark.square" : "square")
                        .imageScale(.large)
                    Text(options[index])
                }.onTapGesture {
                    checked = index
                }
            }
        }
    }
}
