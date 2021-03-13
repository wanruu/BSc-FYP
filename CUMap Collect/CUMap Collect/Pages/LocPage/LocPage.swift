import SwiftUI

struct LocPage: View {
    @Environment(\.colorScheme) var colorScheme
    
    @Binding var locations: [Location]
    @State var selectedLoc: Location? = nil
    @Binding var current: Coor3D
    
    @Binding var showToolBar: Bool
    @State var showLocList: Bool = false
    @State var showNewLocSheet: Bool = false
    
    var body: some View {
        ZStack {
            LocMapView(locations: $locations, selectedLoc: $selectedLoc)
            searchArea
            addButton
            sheet
        }
        .navigationBarHidden(true)
        .onChange(of: selectedLoc, perform: { value in
            if let _ = value {
                showToolBar = false
            } else {
                showToolBar = true
            }
        })
        .sheet(isPresented: $showNewLocSheet) {
            NewLocView(locations: $locations, current: $current)
        }
    }
    
    var searchArea: some View {
        VStack {
            HStack {
                NavigationLink(destination: LocListView(placeholder: "Search for location", keyword: selectedLoc?.nameEn ?? "", locations: locations, selectedLoc: $selectedLoc, showing: $showLocList), isActive: $showLocList) {
                    Text(selectedLoc?.nameEn ?? "Search for location")
                        .foregroundColor(selectedLoc == nil ? .secondary : .primary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                selectedLoc == nil ? nil : Image(systemName: "xmark").contentShape(Rectangle()).onTapGesture { selectedLoc = nil }
            }
            .padding()
            .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.secondary, lineWidth: 1))
            .background(colorScheme == .light ? Color.white : Color.black)
            .cornerRadius(16)
            .clipped()
            .shadow(radius: 5)
            .padding()
            Spacer()
        }
    }
    
    var sheet: some View {
        BottomSheetView(showing: .constant(selectedLoc != nil)) {
            LocDetailsView(locations: $locations, loc: $selectedLoc)
        }
    }
    
    var addButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    showNewLocSheet = true
                }) {
                    Image(systemName: "plus")
                        .resizable()
                        .frame(width: UIScreen.main.bounds.width * 0.05, height: UIScreen.main.bounds.width * 0.05, alignment: .center)
                        .scaledToFit()
                        .padding(10)
                }
                .buttonStyle(AddButtonStyle(fgColor: .white, bgColor: .accentColor))
                .padding()
                .padding()
            }
        }
    }
}
