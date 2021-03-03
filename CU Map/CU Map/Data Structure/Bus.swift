import Foundation

struct Bus: Identifiable {
    var id: String
    var line: String
    var nameEn: String
    var nameZh: String
    var serviceHour: ServiceHour
    var serviceDay: ServiceDay
    var departTime: [Int]
    var stops: [Location]
    
    func toBusResponse() -> BusResponse {
        var serviceDay: Int
        switch self.serviceDay {
        case .ordinaryDay: serviceDay = 0
        case .holiday: serviceDay = 1
        case .teachingDay: serviceDay = 2
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        let serviceHour = formatter.string(from: self.serviceHour.startTime) + "-" + formatter.string(from: self.serviceHour.endTime)
        var stops: [String] = []
        for stop in self.stops {
            stops.append(stop.id)
        }
        return BusResponse(_id: id, line: line, name_en: nameEn, name_zh: nameZh, serviceHour: serviceHour, serviceDay: serviceDay, stops: stops, departTime: departTime)
    }
}

struct ServiceHour {
    var startTime: Date
    var endTime: Date
    func toString() -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.locale = Locale(identifier: "en_US")
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: startTime) + " - " + formatter.string(from: endTime)
    }
}

enum ServiceDay {
    case holiday
    case teachingDay
    case ordinaryDay
}


struct BusResponse: Codable {
    var _id: String
    var line: String
    var name_en: String
    var name_zh: String
    var serviceHour: String // eg. 07:40-18:40
    var serviceDay: Int // 0: Mon-Sat, 1: Sun&PH, 2: teach
    var stops: [String]
    var departTime: [Int]
    
    func toBus(locations: [Location]) -> Bus {
        var serviceDay: ServiceDay
        switch self.serviceDay {
        case 0: serviceDay = .ordinaryDay
        case 1: serviceDay = .holiday
        case 2: serviceDay = .teachingDay
        default: serviceDay = .ordinaryDay
        }
        let times = serviceHour.split(separator: "-")
        let startTimes = times[0].split(separator: ":")
        let endTimes = times[1].split(separator: ":")
        let startTime = Date(timeIntervalSince1970: TimeInterval(Int(startTimes[0])! * 3600 + Int(startTimes[1])! * 60))
        let endTime = Date(timeIntervalSince1970: TimeInterval(Int(endTimes[0])! * 3600 + Int(endTimes[1])! * 60))
        var stops: [Location] = []
        for stopId in self.stops {
            let stop = locations.first(where: { $0.id == stopId })
            if stop != nil {
                stops.append(stop!)
            }
        }
        return Bus(id: _id, line: line, nameEn: name_en, nameZh: name_zh, serviceHour: ServiceHour(startTime: startTime, endTime: endTime), serviceDay: serviceDay, departTime: departTime, stops: stops)
    }
}
