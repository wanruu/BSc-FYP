import SwiftUI

struct PCPage: View {
    
    
    @Binding var showToolBar: Bool
    
    @EnvironmentObject var store: Store
    var binding: Binding<AppState.PCPage>{
        $store.appState.pcPage
    }
    
    @State var selectedLoc: Location? = nil
    
    @State var showLocList = false
    @State var showNavi = false
    @State var showBottomSheet = false
    
    var body: some View {
        ZStack {
            VStack(alignment: .leading, spacing: 0) {
           /*     HStack(spacing: 30) {
                    Image(systemName: "person.fill")
                        .resizable()
                        .foregroundColor(Color.secondary)
                        .frame(width: 40, height: 40)
                        .padding(10)
                        .background(Circle().stroke(Color.secondary, lineWidth: 4))
                    Text("Your name")
                        .font(.headline)
                    Spacer()
                }.padding()
                
                Divider()
                 */
                
                contentView
                
            }
            
            SheetView(showNavi: $showNavi, showBottomSheet: $showBottomSheet, selectedLoc: $selectedLoc, height: .large)
            
        }
        .navigationBarHidden(true)
        .onChange(of: showBottomSheet){ _ in
            showToolBar = !showBottomSheet
        }
    }
    
    
    
    var contentView: some View {
        ScrollView {
         VStack(alignment: .leading) {
            /*      HStack {
                    Image(systemName: "bus")
                    Text("Saved buses").font(.subheadline)
                }.frame(height: 54)
                
                if binding.savedBuses.wrappedValue.isEmpty {
                    Text("Empty").italic().foregroundColor(Color.secondary).padding()
                }else{
                    ForEach(binding.savedBuses.wrappedValue) { bus in
                        BusCell(bus: bus)
                    }
                }
                */
                
                HStack {
                    Image(systemName: "building.2")
                    Text("Saved locations").font(.subheadline)
                }.frame(height: 54)
                
                if binding.savedLocs.wrappedValue.isEmpty {
                    Text("Empty").italic().foregroundColor(Color.secondary).padding()
                }else{
                    ForEach(binding.savedLocs.wrappedValue) { loc in
                        LocCell(loc: loc)
                            .onTapGesture {
                                self.selectedLoc = loc
                                withAnimation {
                                    self.showBottomSheet = true
                                }
                            }
                    }
                }
            }
            .padding(10)
        }
    }
    
    
}




struct LocCell: View {
    
    @EnvironmentObject var locationModel: LocationModel
    var loc: Location
    
    @State var showNavi = false
    
    var body: some View {
        VStack(spacing: 0){
            HStack{
                Text(loc.nameEn)
                Spacer()
                Color(.secondarySystemBackground).frame(width: 1, height: 20)
                    .padding(.trailing, 20)
                
                
                NavigationLink(destination: NaviPage(
                                startLoc: Location(id: UUID().uuidString,
                                                   nameEn: "Your Location",
                                                   nameZh: "你的位置",
                                                   latitude: locationModel.current.latitude,
                                                   longitude: locationModel.current.longitude,
                                                   altitude: locationModel.current.altitude,
                                                   type: .user),
                                endLoc: loc, showing: $showNavi),
                               isActive: $showNavi) {
                    
                    Image(systemName: "arrow.right")
                        .imageScale(.large)
                    
                }
            }.frame(height: 44)
            
            Color(.secondarySystemBackground).frame(height: 1)
        }.padding(.horizontal, 15)
        .contentShape(Rectangle())
    }
}

struct BusCell: View {
    var bus: Bus
    var body: some View {
        VStack(spacing: 0){
            HStack{
                Text(bus.nameEn)
                Spacer()
                Color(.secondarySystemBackground).frame(width: 1, height: 20)
                    .padding(.trailing, 20)
                
                Image(systemName: "arrow.right")
                    .imageScale(.large)
                
            }.frame(height: 44)
            
            Color(.secondarySystemBackground).frame(height: 1)
        }.padding(.horizontal, 15)
        
        .contentShape(Rectangle())
    }
}
