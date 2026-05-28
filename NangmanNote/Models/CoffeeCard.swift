import Foundation
import SwiftData

@Model
final class CoffeeCard {
    @Attribute(.unique) var id: UUID
    var capturedAt: Date
    var backImagePath: String
    var inputModeRaw: String
    var visitedOn: Date
    var userRating: Int?
    var userMemo: String?
    var parsingConfidence: Double?

    var blendName: String?
    var originCountry: String?
    var originRegion: String?
    var variety: String?
    var processRaw: String?
    var roastLevelRaw: String?

    var cafe: Cafe?
    @Relationship(inverse: \TastingNote.cards) var tastingNotes: [TastingNote] = []

    init(
        id: UUID = UUID(),
        capturedAt: Date = .now,
        backImagePath: String = "",
        inputMode: InputMode = .auto,
        visitedOn: Date = .now
    ) {
        self.id = id
        self.capturedAt = capturedAt
        self.backImagePath = backImagePath
        self.inputModeRaw = inputMode.rawValue
        self.visitedOn = visitedOn
    }

    var inputMode: InputMode {
        get { InputMode(rawValue: inputModeRaw) ?? .auto }
        set { inputModeRaw = newValue.rawValue }
    }

    var process: ProcessMethod? {
        get { processRaw.flatMap(ProcessMethod.init(rawValue:)) }
        set { processRaw = newValue?.rawValue }
    }

    var roastLevel: RoastLevel? {
        get { roastLevelRaw.flatMap(RoastLevel.init(rawValue:)) }
        set { roastLevelRaw = newValue?.rawValue }
    }

    var displayName: String {
        if let blend = blendName, !blend.isEmpty { return blend }
        let parts = [originCountry, originRegion, variety].compactMap { $0 }
        return parts.isEmpty ? "이름 없음" : parts.joined(separator: " ")
    }
}
