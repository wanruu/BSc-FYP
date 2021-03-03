import SwiftUI

struct LocPage: View {
    @State var locations: [Location]
    @State var selectedLoc: Location? = nil
    
    @State var showLocList = false
    
    @Binding var pageType: PageType

    var body: some View {
        ZStack {
            LocMapView(locations: locations, selectedLoc: $selectedLoc)
                .ignoresSafeArea(.all)
            VStack {
                HStack {
                    NavigationLink(destination: LocListView(placeholder: "Search for location", keyword: selectedLoc?.nameEn ?? "", locations: locations, showCurrent: false, selectedLoc: $selectedLoc, showing: $showLocList), isActive: $showLocList) {
                        Text(selectedLoc?.nameEn ?? "Search for location")
                            .foregroundColor(selectedLoc == nil ? .secondary : .primary)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                    selectedLoc == nil ? nil : Image(systemName: "xmark").contentShape(Rectangle()).onTapGesture { selectedLoc = nil }
                }
                .padding()
                .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.secondary, lineWidth: 1))
                .background(Color.white)
                .cornerRadius(16)
                .clipped()
                .shadow(radius: 5)
                .padding()
                Spacer()
            }
        }
        .navigationBarHidden(true)
    }
}
