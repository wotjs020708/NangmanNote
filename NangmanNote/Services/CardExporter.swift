import Foundation

struct CardExportPayload: Codable {
    let exportedAt: Date
    let cardCount: Int
    let cards: [CardExportItem]
}

struct CardExportItem: Codable {
    let id: UUID
    let capturedAt: Date
    let visitedOn: Date
    let inputMode: String
    let blendName: String?
    let originCountry: String?
    let originRegion: String?
    let variety: String?
    let process: String?
    let roastLevel: String?
    let userRating: Int?
    let userMemo: String?
    let parsingConfidence: Double?
    let cafeName: String?
    let cafeLatitude: Double?
    let cafeLongitude: Double?
    let tastingNotes: [String]
    let blendComponents: [BlendComponentExport]

    init(card: CoffeeCard) {
        self.id = card.id
        self.capturedAt = card.capturedAt
        self.visitedOn = card.visitedOn
        self.inputMode = card.inputMode.rawValue
        self.blendName = card.blendName
        self.originCountry = card.originCountry
        self.originRegion = card.originRegion
        self.variety = card.variety
        self.process = card.processRaw
        self.roastLevel = card.roastLevelRaw
        self.userRating = card.userRating
        self.userMemo = card.userMemo
        self.parsingConfidence = card.parsingConfidence
        self.cafeName = card.cafe?.name
        self.cafeLatitude = card.cafe?.latitude
        self.cafeLongitude = card.cafe?.longitude
        self.tastingNotes = card.tastingNotes.map(\.label)
        self.blendComponents = card.blendComponents.map(BlendComponentExport.init(component:))
    }
}

struct BlendComponentExport: Codable {
    let country: String
    let region: String?
    let variety: String?
    let process: String?
    let ratio: Int?

    init(component: BlendComponent) {
        self.country = component.country
        self.region = component.region
        self.variety = component.variety
        self.process = component.processRaw
        self.ratio = component.ratio
    }
}

@MainActor
enum CardExporter {
    /// JSON으로 내보내기. tmp 디렉토리에 파일 저장 후 URL 반환.
    static func exportJSON(_ cards: [CoffeeCard]) throws -> URL {
        let payload = CardExportPayload(
            exportedAt: .now,
            cardCount: cards.count,
            cards: cards.map(CardExportItem.init(card:))
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        encoder.dateEncodingStrategy = .iso8601

        let data = try encoder.encode(payload)

        let filename = "nangman-export-\(Int(Date().timeIntervalSince1970)).json"
        let url = FileManager.default.temporaryDirectory.appendingPathComponent(filename)
        try data.write(to: url, options: [.atomic])
        return url
    }
}
