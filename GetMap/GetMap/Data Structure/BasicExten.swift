import Foundation
import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(
            #selector(UIResponder.resignFirstResponder),
            to: nil,
            from: nil,
            for: nil
        )
    }
}

extension String: Identifiable {
    public var id: String {
        self
    }
}

extension Int: Identifiable {
    public var id: String {
        String(self)
    }
}
