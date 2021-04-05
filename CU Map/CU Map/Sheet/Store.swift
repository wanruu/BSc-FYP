
import Foundation
import Combine
import SwiftUI
import UIKit

class Store: ObservableObject{
    static let shared = Store()
    private init() {}
    
    
    @Published var appState = AppState()
    
    var locations: [Location] = []
    var buses: [Bus] = []
    var routesOnFoot: [Route] = []
    var routesByBus: [Route] = []
    
    @Published var comments: [String: [Comment]] = [:]
    
    
    func run(){
        
        if let array = UserDefaults.standard.array(forKey: "savedLocs") as? [String]{
            self.appState.locPage.savedLocs = array
            
            self.appState.pcPage.savedLocs = self.locations.filter{ array.contains($0.id) }
        }
        
        //Download Comment
        self.loadComments()
    }
    
    
    func likeLocation(_ obj: Location?){
        guard let id = obj?.id else { return }
        
        var state = self.appState.locPage
        
        if let index = state.savedLocs.firstIndex(of: id){
            state.savedLocs.remove(at: index)
        }else{
            state.savedLocs.append(id)
        }
        self.appState.locPage = state
        
        let array = state.savedLocs
        
        self.appState.pcPage.savedLocs = self.locations.filter{ array.contains($0.id) }
        
    }
    
    
    func comment(_ str: String, locId: String){
        let text = str.trimmingCharacters(in: .whitespacesAndNewlines)
        guard text.count > 0, locId.count > 0 else { return }
        
        Store.shared.endEditing()
        
        let time = Date().timeIntervalSince1970
        print(time)
        let comment = Comment(locId: locId, text: text, time: time)
        self.comments[locId] = [comment] + (self.comments[locId] ?? [])
        
        //Send to server
        self.commentToServer(text, locId: locId)
        
    }
    
    
    func endEditing(){
        UIApplication.shared
            .sendAction(#selector(UIResponder.resignFirstResponder),
                        to: nil, from: nil, for: nil)
    }
    

    private func commentToServer(_ text: String, locId: String){
        guard let url = URL(string: server + "/comment") else { return }
        
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.allHTTPHeaderFields = ["Content-Type": "application/json"]
        
        let params = [
            "text": text,
            "locId": locId
        ]
        
        if let body = try? JSONSerialization.data(withJSONObject: params){
            req.httpBody = body
        }
        
        URLSession.shared.dataTask(with: req) { data, _, error in
            if error == nil {
                //静默更新评论，供下次使用
                self.loadComments()
                
                
                print("data = \(String(data: data ?? Data(), encoding: .utf8) ?? "empty")")
            }
            
            print("error = \(String(describing: error))")
            
        }.resume()
    }
    
  

    

    func loadComments(){
        guard let url = URL(string: server + "/comment") else { return }
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data else { return }
            do {
                let array = try JSONDecoder().decode([Comment].self, from: data)
                
                let locIdArray = array.map{$0.locId}
                
                for locId in locIdArray{
                    self.comments.updateValue(array.filter{ $0.locId == locId }, forKey: locId)
                }
            } catch let error {
                print(error)
            }
        }.resume()
    }
    
}
