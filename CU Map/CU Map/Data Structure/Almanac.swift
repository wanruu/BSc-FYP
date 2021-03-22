import Foundation

enum DayType {
    case holiday, exam, courseSelect, termStart, termEnd, event
}

struct Day {
    var type: DayType
    var description: String
}


