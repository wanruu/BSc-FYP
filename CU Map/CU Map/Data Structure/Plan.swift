import Foundation
import SwiftUI

struct Plan: Identifiable {
    var id = UUID()
    var startLoc: Location?
    var endLoc: Location?
    var routes: [Route]
    var dist: Double // meters
    var time: Double // seconds
    var ascent: Double // meters
    var type: PlanType
}

enum PlanType {
    case byBus
    case onFoot
}

extension PlanType {
    func toImage() -> Image {
        switch self {
        case .byBus: return Image(systemName: "bus")
        case .onFoot: return Image(systemName: "figure.walk")
        }
    }
}
