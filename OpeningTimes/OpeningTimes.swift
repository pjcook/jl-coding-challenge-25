import Foundation

let timeFormatterInput: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "HH:mm"
    return dateFormatter
}()

let timeFormatterOutput: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "ha"
    return dateFormatter
}()

let timeFormatterOutputWithMinutes: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateFormat = "h:mma"
    return dateFormatter
}()

let orderedDaysOfWeek = [
    "Monday",
    "Tuesday",
    "Wednesday",
    "Thursday",
    "Friday",
    "Saturday",
    "Sunday",
]

let dayShortNames = [
    "Monday": "Mon",
    "Tuesday": "Tue",
    "Wednesday": "Wed",
    "Thursday": "Thu",
    "Friday": "Fri",
    "Saturday": "Sat",
    "Sunday": "Sun",
]

func consecutiveDays(_ days: [String]) -> Bool {
    guard let firstDay = days.first else { return false }
    var index: Int = -1
    for i in 0..<orderedDaysOfWeek.count {
        if firstDay == orderedDaysOfWeek[i] {
            index = i
            break
        }
    }
    
    guard index != -1 else { return false }
    
    for day in days {
        guard day == orderedDaysOfWeek[index] else { return false }
        index += 1
        if index >= orderedDaysOfWeek.count { break }
    }
    
    return true
}

struct DayOfWeekDetail: Codable {
    let dayOfWeek: [String]
    let opens: String
    let closes: String
}

extension DayOfWeekDetail: CustomStringConvertible {
    private func convertTime(input: String, date: Date) -> String {
        guard !input.isEmpty else { return "" }
        if input.hasSuffix(":00") {
            return timeFormatterOutput.string(from: date)
        } else {
            return timeFormatterOutputWithMinutes.string(from: date)
        }
    }
    
    var description: String {
        guard
            let openingTime = timeFormatterInput.date(from: opens),
            let closingTime = timeFormatterInput.date(from: closes)
            else {
                return ""
        }
        
        let shortDays = dayOfWeek.compactMap({ dayShortNames[$0] })
        guard shortDays.count == dayOfWeek.count else { return "" }
        var days = ""
        if shortDays.count > 1, consecutiveDays(dayOfWeek) {
            let first = shortDays.first!
            let last = shortDays.last!
            days = first + "-" + last
        } else {
            days = shortDays.joined(separator: ",")
        }

        switch (opens, closes) {
        
        case ("00:00", "00:00"):
            return days + ":Closed"

        default:
            let openingOutput = convertTime(input: opens, date: openingTime)
            let closingOutput = convertTime(input: closes, date: closingTime)
            return days + ":" + openingOutput + "-" + closingOutput

        }
    }
}

struct OpeningHours: Codable {
    let openingHoursSpecification: [DayOfWeekDetail]
}

extension OpeningHours: CustomStringConvertible {
    var description: String {
        return openingHoursSpecification.compactMap { $0.description.isEmpty ? nil : $0.description }.joined(separator: ", ")
    }
}
