import SwiftUI

struct LocListView: View {
    @Binding var locations: [Location]
    @Binding var selectedLoc: Location?
    
    @State var text = ""
    
    @Binding var pageType: LocPageType
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 0) {
                HStack {
                    TextField(NSLocalizedString("search.location", comment: ""), text: $text)
                    text.isEmpty ? nil : Image(systemName: "xmark").contentShape(Rectangle()).onTapGesture { text = "" }
                }
                .padding(10)
                .overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.secondary, lineWidth: 0.5))
                .padding(.leading)
                .padding(.vertical)
                
                Button(action: {
                    pageType = .newLoc
                }) {
                    Image(systemName: "plus.circle")
                        .imageScale(.large)
                }.padding()
            }
            
            
            Divider()
            
            ScrollView(.vertical, showsIndicators: true) {
                VStack(alignment: .leading, spacing: 0) {
                    ForEach(locations) { loc in
                        if text.isEmpty || loc.nameEn.lowercased().contains(text.lowercased()) {
                            Button(action: {
                                selectedLoc = loc
                                pageType = .editLoc
                            }) {
                                HStack(spacing: 20) {
                                    loc.type.toImage()
                                    Text(loc.nameEn)
                                }
                                .padding(.horizontal, 20)
                                .padding(.vertical, 10)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(BackgroundTurnColorButtonStyle(bgColor: CU_PALE_YELLOW.opacity(0.5)))
                        }
                    }
                }
            }
        }
    }
}



