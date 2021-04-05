import Foundation
import SwiftUI

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
        var stops: [String] = []
        for stop in self.stops {
            stops.append(stop.id)
        }
        return BusResponse(_id: id, line: line, name_en: nameEn, name_zh: nameZh, serviceHour: serviceHour.toString(), serviceDay: serviceDay.toInt(), stops: stops, departTime: departTime)
    }
}

struct ServiceHour {
    var startTime: Date
    var endTime: Date

    func toString() -> String {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "HH:mm"
        return formatter.string(from: startTime) + "-" + formatter.string(from: endTime)
    }
}

extension String {
    func toServiceHour() -> ServiceHour {
        let times = self.split(separator: "-")
        let startTimes = times[0].split(separator: ":")
        let endTimes = times[1].split(separator: ":")
        let startTime = Date(timeIntervalSince1970: TimeInterval(Int(startTimes[0])! * 3600 + Int(startTimes[1])! * 60))
        let endTime = Date(timeIntervalSince1970: TimeInterval(Int(endTimes[0])! * 3600 + Int(endTimes[1])! * 60))
        return ServiceHour(startTime: startTime, endTime: endTime)
    }
}

enum ServiceDay {
    case holiday, teachingDay, ordinaryDay, ordinaryNotTeachingDay
    
    func toInt() -> Int {
        switch self {
        case .ordinaryDay: return 0
        case .holiday: return 1
        case .teachingDay: return 2
        case .ordinaryNotTeachingDay: return 3
        }
    }
    
    func toView() -> some View {
        VStack(alignment: .leading) {
            switch self {
            case .holiday:
                Text(NSLocalizedString("Sun & public holidays", comment: ""))
            case .teachingDay:
                Text(NSLocalizedString("Teaching days only", comment: ""))
            case .ordinaryDay:
                Text(NSLocalizedString("Mon - Sat", comment: ""))
                Text("* " + NSLocalizedString("Service suspended on public holidays", comment: "")).font(.footnote).italic().foregroundColor(.gray)
            case .ordinaryNotTeachingDay:
                Text(NSLocalizedString("Mon - Sat", comment: ""))
                Text("* " + NSLocalizedString("Non-teaching days", comment: "")).font(.footnote).italic().foregroundColor(.gray)
            }
        }
    }
}

extension Int {
    func toServiceDay() -> ServiceDay {
        switch self {
        case 0: return .ordinaryDay
        case 1: return .holiday
        case 2: return .teachingDay
        case 3: return .ordinaryNotTeachingDay
        default: return .ordinaryDay
        }
    }
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
        var stops: [Location] = []
        for stopId in self.stops {
            let stop = locations.first(where: { $0.id == stopId })
            if stop != nil {
                stops.append(stop!)
            }
        }
        return Bus(id: _id, line: line, nameEn: name_en, nameZh: name_zh, serviceHour: serviceHour.toServiceHour(), serviceDay: serviceDay.toServiceDay(), departTime: departTime, stops: stops)
    }
}
