import Foundation
import XCTest
@testable import OpeningTimes

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
            let openingOutput = timeFormatterOutput.string(from: openingTime)
            let closingOutput = timeFormatterOutput.string(from: closingTime)
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

class OpeningTimesTests: XCTestCase {

    func test_dateConversion() throws {
        let input = timeFormatterInput.date(from: "14:00")!
        let output = timeFormatterOutput.string(from: input)
        XCTAssertEqual("2pm", output)
    }
    
    func test_simpleExample() throws {
        let openingHours = try readFile("SimpleExample1.json")
        XCTAssertNotNil(openingHours)
        XCTAssertEqual("Mon-Fri:12pm-10pm, Sat-Sun:12pm-11pm", openingHours.description)
    }
    
    func test_complexExample() throws {
        let openingHours = try readFile("ComplexExample1.json")
        XCTAssertNotNil(openingHours)
        XCTAssertEqual("Mon:Closed, Tue-Thu:5pm-10pm, Wed-Thu:12pm-2pm, Fri-Sat:12pm-10pm, Sun:12pm-5pm", openingHours.description)
    }
}

extension OpeningTimesTests {
    enum InputErrors: Error {
        case invalidFilename
        case invalidFileData
    }
    
    private func readFile(_ named: String) throws -> OpeningHours {
        guard let url = Bundle(for: Self.self).url(forResource: named, withExtension: nil) else {
            throw InputErrors.invalidFilename
        }
        let data = try Data(contentsOf: url)
        let result = try JSONDecoder().decode(OpeningHours.self, from: data)
        return result
    }
}
