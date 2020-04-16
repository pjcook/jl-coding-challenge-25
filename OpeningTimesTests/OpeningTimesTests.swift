import XCTest
@testable import OpeningTimes

class OpeningTimesTests: XCTestCase {
    
    func test_simpleExample1() throws {
        let openingHours = try readFile("SimpleExample1.json")
        XCTAssertNotNil(openingHours)
        XCTAssertEqual("Mon-Fri:12pm-10pm, Sat-Sun:12pm-11pm", openingHours.description)
    }
    
    func test_simpleExample2() throws {
        let openingHours = try readFile("SimpleExample2.json")
        XCTAssertNotNil(openingHours)
        XCTAssertEqual("Mon-Fri:12:30pm-10pm, Sat-Sun:12:30pm-11pm", openingHours.description)
    }
    
    func test_complexExample() throws {
        let openingHours = try readFile("ComplexExample1.json")
        XCTAssertNotNil(openingHours)
        XCTAssertEqual("Mon:Closed, Tue-Thu:5pm-10pm, Wed-Thu:12pm-2pm, Fri-Sat:12pm-10:30pm, Sun:12pm-5pm", openingHours.description)
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
