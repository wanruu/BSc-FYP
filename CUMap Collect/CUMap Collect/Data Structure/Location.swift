import Foundation
import SwiftUI

struct Location: Identifiable, Equatable {
    var id: String
    var nameEn: String
    var nameZh: String
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var type: LocationType
    
    func toLocResponse() -> LocResponse {
        return LocResponse(_id: id, name_en: nameEn, name_zh: nameZh, latitude: latitude, longitude: longitude, altitude: altitude, type: self.type.toInt())
    }
    
    static func == (location1: Location, location2: Location) -> Bool {
        return location1.id == location2.id && location1.nameEn == location2.nameEn &&
            location1.nameZh == location2.nameZh && location1.latitude == location2.latitude &&
            location1.longitude == location2.longitude && location1.altitude == location2.altitude &&
            location1.type == location2.type
    }
}

enum LocationType {
    case building
    case busStop
    case canteen
    case office
    case sportsArea
    case medical
    case bank
    case residence
    case sight
    case user
}

extension LocationType {
    func toString() -> String {
        switch self {
        case .building: return "Building"
        case .busStop: return "Bus stop"
        case .canteen: return "Canteen"
        case .office: return "Office"
        case .sportsArea: return "Sports area"
        case .medical: return "Medical"
        case .bank: return "Bank"
        case .residence: return "Residence"
        case .sight: return "Sight"
        case .user: return "User"
        }
    }
    
    func toInt() -> Int {
        switch self {
        case .building: return 0
        case .busStop: return 1
        case .canteen: return 2
        case .office: return 3
        case .sportsArea: return 4
        case .medical: return 5
        case .bank: return 6
        case .residence: return 7
        case .sight: return 8
        case .user: return 9
        }
    }
    
    func toImage() -> Image {
        var systemName: String
        switch self {
        case .building: systemName = "building.2"
        case .busStop: systemName = "bus"
        case .canteen: systemName = "tuningfork"
        case .office: systemName = "bag"
        case .sportsArea: systemName = "sportscourt"
        case .medical: systemName = "cross"
        case .bank: systemName = "dollarsign.circle"
        case .residence: systemName = "house"
        case .sight: systemName = "photo"
        case .user: systemName = "location.fill"
        }
        return Image(systemName: systemName)
    }
    
    func toUIImage() -> UIImage {
        var systemName: String
        switch self {
        case .building: systemName = "building.2"
        case .busStop: systemName = "bus"
        case .canteen: systemName = "tuningfork"
        case .office: systemName = "bag"
        case .sportsArea: systemName = "sportscourt"
        case .medical: systemName = "cross"
        case .bank: systemName = "dollarsign.circle"
        case .residence: systemName = "house"
        case .sight: systemName = "photo"
        case .user: systemName = "location.fill"
        }
        return UIImage(systemName: systemName)!
    }
}

extension String {
    func toLocationType() -> LocationType {
        switch self {
        case "Building": return .building
        case "Bus stop": return .busStop
        case "Canteen": return .canteen
        case "Office": return .office
        case "Sports area": return .sportsArea
        case "Medical": return .medical
        case "Bank": return .bank
        case "Residence": return .residence
        case "Sight": return .sight
        case "User": return .user
        default: print("fix Data structure: 117"); return .building
        }
    }
}

extension Int {
    func toLocationType() -> LocationType {
        switch self {
        case 0: return .building
        case 1: return .busStop
        case 2: return .canteen
        case 3: return .office
        case 4: return .sportsArea
        case 5: return .medical
        case 6: return .bank
        case 7: return .residence
        case 8: return .sight
        case 9: return .user
        default: print("fix Data structure: 135"); return .building
        }
    }
    
    func isValidLocationType() -> Bool {
        if self >= 0 && self <= 9 {
            return true
        }
        return false
    }
}

struct LocResponse: Codable {
    var _id: String
    var name_en: String
    var name_zh: String
    var latitude: Double
    var longitude: Double
    var altitude: Double
    var type: Int
    
    func toLocation() -> Location {
        return Location(id: _id, nameEn: name_en, nameZh: name_zh, latitude: latitude, longitude: longitude, altitude: altitude, type: type.toLocationType())
    }
}
