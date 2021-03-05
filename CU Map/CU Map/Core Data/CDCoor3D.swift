import Foundation

public class CDCoor3D: NSObject, NSSecureCoding {
    public static var supportsSecureCoding: Bool = true
    
    public func encode(with coder: NSCoder) {
        coder.encode(latitude, forKey: "latitude")
        coder.encode(longitude, forKey: "longitude")
        coder.encode(altitude, forKey: "altitude")
    }
    
    public required init?(coder: NSCoder) {
        latitude = coder.decodeDouble(forKey: "latitude")
        longitude = coder.decodeDouble(forKey: "longitude")
        altitude = coder.decodeDouble(forKey: "altitude")
    }
    
    var latitude: Double = -1
    var longitude: Double = -1
    var altitude: Double = -1
    
    init(point: Coor3D) {
        latitude = point.latitude
        longitude = point.longitude
        altitude = point.altitude
    }
    
    func toCoor3D() -> Coor3D {
        Coor3D(latitude: latitude, longitude: longitude, altitude: altitude)
    }
}

class CDCoor3DValueTransformer: NSSecureUnarchiveFromDataTransformer {
    static let name = NSValueTransformerName(rawValue: String(describing: CDCoor3DValueTransformer.self))


    override static var allowedTopLevelClasses: [AnyClass] {
        return [CDCoor3D.self]
    }

    public static func register() {
        let transformer = CDCoor3DValueTransformer()
        ValueTransformer.setValueTransformer(transformer, forName: name)
    }
}
