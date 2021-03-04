import SwiftUI

enum LocPageType {
    case locList
    case editLoc
    case newLoc
}

struct LocPage: View {
    
    @State var locations: [Location] = []
    @State var selectedLoc: Location? = nil
    @Binding var current: Coor3D
    
    @State var pageType: LocPageType = .locList
    
    var body: some View {
        VStack(spacing: 0) {
            LocMapView(locations: $locations, selectedLoc: $selectedLoc)
                .ignoresSafeArea(.all)
            
            Divider()
            switch pageType {
            case .locList :
                LocListView(locations: $locations, selectedLoc: $selectedLoc, pageType: $pageType)
                    .frame(height: UIScreen.main.bounds.height * 0.33, alignment: .topLeading)
            case .editLoc:
                EditLocView(locations: $locations, id: selectedLoc!.id, nameEn: selectedLoc!.nameEn, nameZh: selectedLoc!.nameZh, latitude: String(selectedLoc!.latitude), longitude: String(selectedLoc!.longitude), altitude: String(selectedLoc!.altitude), type: String(selectedLoc!.type.toInt()), isEditing: false, pageType: $pageType)
                    .frame(height: UIScreen.main.bounds.height * 0.33, alignment: .topLeading)
            case .newLoc:
                NewLocView(locations: $locations, selectedLoc: $selectedLoc, latitude: String(current.latitude), longitude: String(current.longitude), altitude: String(current.altitude), pageType: $pageType)
                    .frame(height: UIScreen.main.bounds.height * 0.33, alignment: .topLeading)
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            loadLocations()
        }
    }
    
    
    private func loadLocations() {
        let url = URL(string: server + "/locations")!
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let locRes = try JSONDecoder().decode([LocResponse].self, from: data)
                var locations: [Location] = []
                for loc in locRes {
                    locations.append(loc.toLocation())
                }
                self.locations = locations
            } catch let error {
                print(error)
            }
        }.resume()
    }
}
