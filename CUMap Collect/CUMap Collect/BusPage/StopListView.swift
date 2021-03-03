import SwiftUI

struct StopListArrayView: View {
    @Binding var locations: [Location]
    @Binding var chosenStops: [Location]
    @State var placeholder = ""
    @State var text = ""
    
    @Binding var showing: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "chevron.left")
                    .imageScale(.large)
                    .contentShape(Rectangle())
                    .onTapGesture { showing.toggle() }
                TextField(placeholder, text: $text)
                if !text.isEmpty {
                    Image(systemName: "xmark")
                        .imageScale(.large)
                        .contentShape(Rectangle())
                        .onTapGesture { text = "" }
                }
            }
            .padding().overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.5)).padding()
            
            Divider()
            
            List {
                ForEach(locations) { location in
                    if location.type == .busStop  && ( text.isEmpty || location.nameEn.lowercased().contains(text.lowercased()) ) {
                        Button(action: {
                            chosenStops.append(location)
                            showing.toggle()
                        }) {
                            Text(location.nameEn)
                        }
                    }
                }
            }
        }.navigationBarHidden(true)
    }
}

struct StopListSingleView: View {
    @Binding var locations: [Location]
    @Binding var chosenStop: Location?
    @State var placeholder = ""
    @State var text = ""
    
    @Binding var showing: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "chevron.backward").contentShape(Rectangle()).onTapGesture { showing.toggle() }
                TextField(placeholder, text: $text)
                if !text.isEmpty {
                    Image(systemName: "xmark")
                        .imageScale(.large)
                        .contentShape(Rectangle())
                        .onTapGesture { text = "" }
                }
            }
            .padding().overlay(RoundedRectangle(cornerRadius: 5).stroke(Color.gray, lineWidth: 0.5)).padding()
            
            Divider()
            
            List {
                ForEach(locations) { location in
                    if location.type == .busStop  && ( text.isEmpty || location.nameEn.lowercased().contains(text.lowercased()) ) {
                        Button(action: {
                            chosenStop = location
                            // text = location.nameEn
                            showing.toggle()
                        }) {
                            Text(location.nameEn)
                        }
                    }
                }
            }
        }
        .navigationBarHidden(true)
    }
}

