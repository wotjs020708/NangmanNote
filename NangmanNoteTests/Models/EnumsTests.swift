import Testing
@testable import NangmanNote

struct EnumsTests {
    @Test func inputModeCases() {
        #expect(InputMode.allCases.contains(.auto))
        #expect(InputMode.allCases.contains(.manual))
        #expect(InputMode.allCases.count == 2)
    }

    @Test func processMethodRawValues() {
        #expect(ProcessMethod.washed.rawValue == "washed")
        #expect(ProcessMethod.natural.rawValue == "natural")
        #expect(ProcessMethod.honey.rawValue == "honey")
        #expect(ProcessMethod.anaerobic.rawValue == "anaerobic")
        #expect(ProcessMethod.redHoney.rawValue == "redHoney")
        #expect(ProcessMethod(rawValue: "washed") == .washed)
        #expect(ProcessMethod(rawValue: "invalid") == nil)
    }

    @Test func roastLevelOrdered() {
        let all = RoastLevel.allCases
        #expect(all.count == 5)
        #expect(all.contains(.light))
        #expect(all.contains(.medium))
        #expect(all.contains(.dark))
    }

    @Test func noteCategoryCount() {
        #expect(NoteCategory.allCases.count == 8)
        #expect(NoteCategory.fruit.rawValue == "fruit")
        #expect(NoteCategory.floral.rawValue == "floral")
    }

    @Test func frontBackgroundTypeSolid() {
        let bg = FrontBackgroundType.solid(hex: "#FFFFFF")
        guard case let .solid(hex) = bg else {
            Issue.record("Expected .solid")
            return
        }
        #expect(hex == "#FFFFFF")
    }

    @Test func frontBackgroundTypeGradient() {
        let bg = FrontBackgroundType.gradient(from: "#000000", to: "#FFFFFF")
        guard case let .gradient(from, to) = bg else {
            Issue.record("Expected .gradient")
            return
        }
        #expect(from == "#000000")
        #expect(to == "#FFFFFF")
    }

    @Test func frontBackgroundTypeEquatable() {
        let a = FrontBackgroundType.solid(hex: "#000")
        let b = FrontBackgroundType.solid(hex: "#000")
        let c = FrontBackgroundType.solid(hex: "#FFF")
        #expect(a == b)
        #expect(a != c)
    }
}
