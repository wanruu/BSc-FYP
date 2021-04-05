
import SwiftUI
import UIKit

struct SheetView: View{
    
    
    @EnvironmentObject var store: Store
    
    @EnvironmentObject var locationModel: LocationModel
    
    
    @Binding var showNavi: Bool
    @Binding var showBottomSheet: Bool
    @Binding var selectedLoc: Location?
    
    @State var height: BottomSheetHeight
    
    var binding: Binding<AppState.LocPage>{
        $store.appState.locPage
    }
    
    
    @State var text = ""
    
    
    let keyboardWillShow = NotificationCenter.default.publisher(for: UIResponder.keyboardWillShowNotification)
    let keyboardWillHide = NotificationCenter.default.publisher(for: UIResponder.keyboardWillHideNotification)
    @State var bottomHeight: CGFloat = 0
    
    
    var body: some View{
        BottomSheetView(showing: $showBottomSheet,
                        height: $height,
                        heightChanged: { height in
                            self.height = height
                        }) {
            if let loc = selectedLoc {
                VStack(spacing: 0){
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Text(loc.nameEn).font(.headline)
                            Text(loc.type.toString()).font(.subheadline)
                            
                            NavigationLink(destination: NaviPage(startLoc: Location(id: UUID().uuidString, nameEn: "Your Location", nameZh: "你的位置", latitude: locationModel.current.latitude, longitude: locationModel.current.longitude, altitude: locationModel.current.altitude, type: .user), endLoc: loc, showing: $showNavi), isActive: $showNavi) {
                                Text("Directions")
                            }
                        }
                        
                        Spacer()
                        
                        Button(action: {
                            Store.shared.likeLocation(selectedLoc)
                        }){
                            Group{
                                if binding.savedLocs.wrappedValue.contains(selectedLoc?.id ?? ""){
                                    Image(systemName: "suit.heart.fill")
                                        .imageScale(.large)
                                        .foregroundColor(Color(.systemRed))
                                }else{
                                    Image(systemName: "suit.heart")
                                        .imageScale(.large)
                                        .foregroundColor(Color(.secondaryLabel))
                                }
                            }
                        }.frame(width: 44, height: 44)
                    }.padding(.horizontal, 10)
                    
                    Divider().padding(10)
                    
                    centerView
                    
                    if self.height == .large{
                        commentView
                    }
                    
                    Color.clear.frame(height: self.bottomHeight)
                }
            }
        }
        .onReceive(keyboardWillShow) { res in
            if let userInfo = res.userInfo,
               let rect = userInfo["UIKeyboardBoundsUserInfoKey"] as? CGRect{
                print("res show = \(rect)")
                
                self.bottomHeight = rect.height - 10
            }
        }
        .onReceive(keyboardWillHide) { _ in
            self.bottomHeight = 0
        }
        
        
    }
    
    var centerView: some View{
        
        Group{
            if let comments = $store.comments.wrappedValue[selectedLoc?.id ?? ""]{
                
                List{
                    Image(selectedLoc?.nameEn ?? "pic")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(height: 200)
                        .cornerRadius(10)
                    
                    ForEach(comments, id: \.self){ obj in
                        VStack(alignment: .leading){
                            Text(obj.text)
                                .font(.system(size: 16))
                            HStack{
                                Spacer()
                                Text(createDateTime(timestamp: obj.time))
                            }.font(.system(size: 12))
                            .foregroundColor(Color(.secondaryLabel))
                        }.padding(.vertical, 5)
                    }
                }.listStyle(PlainListStyle())
            }else{
                VStack{
                    List{
                        Image(selectedLoc?.nameEn ?? "pic")
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(height: 200)
                            .cornerRadius(10)
                    }.listStyle(PlainListStyle())
                    .frame(height: 200)
                    
                    Text("No comments")
                        .foregroundColor(Color(.secondaryLabel))
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    
                }
            }
        }
        
        
    }
    
    
    var commentView: some View{
        HStack(spacing: 0){
            TextField("Input comment", text: $text)
                .padding(.horizontal, 10)
                .frame(height: 44)
                .background(Color(.secondarySystemBackground))
                .cornerRadius(10)
            
            Button(action: {
                Store.shared.comment(text, locId: selectedLoc?.id ?? "")
                self.text = ""
            }){
                Text("Send").bold()
                    .frame(height: 44)
                    .padding(.horizontal, 10)
                    .font(.system(size: 16))
            }
        }.padding(10)
    }
    
}


func createDateTime(timestamp: Double) -> String {
    var strDate = "undefined"
        
        let unixTime = timestamp/1000
        let date = Date(timeIntervalSince1970: unixTime)
        let dateFormatter = DateFormatter()
        let timezone = TimeZone.current.abbreviation() ?? "CET"  // get current TimeZone abbreviation or set to CET
        dateFormatter.timeZone = TimeZone(abbreviation: timezone) //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "dd.MM.yyyy HH:mm" //Specify your format that you want
        strDate = dateFormatter.string(from: date)
    
        
    return strDate
}
