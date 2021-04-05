import SwiftUI

struct LocListView: View {
    
    @EnvironmentObject var store: Store
    @EnvironmentObject var locationModel: LocationModel
    
    // search box
    @State var placeholder: String = ""
    @State var keyword: String = ""
    
    // location list
    //@State var locations: [Location] = []
    @State var showCurrent: Bool = true
    
    // chosen location
    @Binding var selectedLoc: Location?
    
    @Binding var showing: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            // text field
            HStack(spacing: 20) {
                Image(systemName: "chevron.backward")
                    .imageScale(.large)
                    .onTapGesture {
                        showing.toggle()
                    }
                TextField(NSLocalizedString(placeholder, comment: ""), text: $keyword)
                keyword.isEmpty ? nil : Image(systemName: "xmark").imageScale(.large).onTapGesture { keyword = "" }
            }
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.gray, lineWidth: 0.8))
            .padding()

            Divider()
            
            // list
            ScrollView {
                VStack(spacing: 0) {
                    // current location
                    if showCurrent {
                        LocListItemView(loc: Location(id: UUID().uuidString, nameEn: "Your Location", nameZh: "你的位置", latitude: locationModel.current.latitude, longitude: locationModel.current.longitude, altitude: locationModel.current.altitude, type: LocationType.user), imageColor: .accentColor, selectedLoc: $selectedLoc, showing: $showing)
                    }
                    
                    // other locations
                    ForEach(store.locations) { loc in
                        if keyword.isEmpty || loc.nameEn.lowercased().contains(keyword.lowercased()) {
                            LocListItemView(loc: loc, imageColor: .primary, selectedLoc: $selectedLoc, showing: $showing)
                        }
                    }
                }
            }
            // end of scrollview
        }
        .navigationBarHidden(true)
    }
}

struct LocListItemView: View {
    @State var loc: Location
    
    var imageColor: Color
    
    @Binding var selectedLoc: Location?
    @Binding var showing: Bool
    
    var body: some View {
        Button(action: {
            selectedLoc = loc
            showing.toggle()
        }) {
            HStack(spacing: 20) {
                loc.type.toImage().imageScale(.large).foregroundColor(imageColor)
                Text(loc.nameEn).foregroundColor(.primary)
                Spacer()
            }
            .padding(.horizontal)
            .padding(10)
            .contentShape(Rectangle())
        }
        .buttonStyle(RoundedShrinkDarkerButtonStyle(bgColor: CU_PALE_YELLOW))
        Divider().padding(.horizontal)
    }
}



struct LocListView_Previews: PreviewProvider {
    static var previews: some View {
        LocListView(selectedLoc: .constant(nil), showing: .constant(true))
            .environmentObject(LocationModel())
    }
}
