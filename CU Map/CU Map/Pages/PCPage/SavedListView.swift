
import SwiftUI

struct SavedListView: View {
    @State var savedBuses: [Bus] = []
    @State var savedLocs: [Location] = []
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "bus")
                    Text("Saved buses").font(.subheadline)
                }.padding(.horizontal)
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(savedBuses) { bus in
                            
                        }
                    }
                    if savedBuses.isEmpty {
                        Text("Empty").italic().foregroundColor(Color.secondary).padding()
                    }
                }
                
                HStack {
                    Image(systemName: "building.2")
                    Text("Saved locations").font(.subheadline)
                }.padding(.horizontal)
                
                ScrollView(.horizontal) {
                    HStack {
                        ForEach(savedLocs) { loc in
                            
                        }
                    }
                    if savedLocs.isEmpty {
                        Text("Empty").italic().foregroundColor(Color.secondary).padding()
                    }
                }
                
            }
            .padding(.top)
        }
    }
}
