import Foundation

extension String: Identifiable {
    public var id: String {
        self
    }
}

extension Int: Identifiable {
    public var id: Int {
        self
    }
}
