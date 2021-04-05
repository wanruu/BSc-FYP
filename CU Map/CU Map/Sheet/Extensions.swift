

import Foundation
import SwiftUI
import UIKit


let dateFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}()


extension Double{
    
    var dateString: String{
        let date = Date(timeIntervalSince1970: self)
        return dateFormatter.string(from: date)
    }
    
}


struct Device{
    
    static var width: CGFloat {
        return UIScreen.main.bounds.width
    }
    
    static var height: CGFloat {
        return UIScreen.main.bounds.height
    }
    
    static var statusBarHeight: CGFloat {
        let window = UIApplication.shared.windows.first
        return window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
    }
    
    static var bottomHeight: CGFloat{
        let height = UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
        print("height = \(height)")
        return height
    }
}
