import Testing
import SwiftData
import Foundation
@testable import NangmanNote

@MainActor
struct CardExporterTests {
    private func makeContainer() throws -> ModelContainer {
        try ModelContainer(
            for: CoffeeCard.self, Cafe.self, TastingNote.self, BlendComponent.self,
                TextLayer.self, StickerLayer.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    @Test func exportEmpty() throws {
        let url = try CardExporter.exportJSON([])
        let data = try Data(contentsOf: url)
        let payload = try JSONDecoder.iso.decode(CardExportPayload.self, from: data)
        #expect(payload.cardCount == 0)
        #expect(payload.cards.isEmpty)

        try? FileManager.default.removeItem(at: url)
    }

    @Test func exportSingleCard() throws {
        let card = CoffeeCard(backImagePath: "test.jpg", inputMode: .auto)
        card.originCountry = "Ethiopia"
        card.variety = "Heirloom"
        card.processRaw = "washed"
        card.userRating = 5
        card.userMemo = "맛있다"

        let url = try CardExporter.exportJSON([card])
        let data = try Data(contentsOf: url)
        let payload = try JSONDecoder.iso.decode(CardExportPayload.self, from: data)

        #expect(payload.cardCount == 1)
        let item = try #require(payload.cards.first)
        #expect(item.originCountry == "Ethiopia")
        #expect(item.variety == "Heirloom")
        #expect(item.process == "washed")
        #expect(item.userRating == 5)
        #expect(item.userMemo == "맛있다")

        try? FileManager.default.removeItem(at: url)
    }

    @Test func exportBlendComponents() throws {
        let card = CoffeeCard(inputMode: .auto)
        card.blendName = "햇살 블렌드"
        let c1 = BlendComponent(country: "Ethiopia", process: .redHoney, ratio: 65)
        let c2 = BlendComponent(country: "Colombia", process: .washed, ratio: 35)
        card.blendComponents = [c1, c2]

        let url = try CardExporter.exportJSON([card])
        let data = try Data(contentsOf: url)
        let payload = try JSONDecoder.iso.decode(CardExportPayload.self, from: data)

        let item = try #require(payload.cards.first)
        #expect(item.blendName == "햇살 블렌드")
        #expect(item.blendComponents.count == 2)
        #expect(item.blendComponents[0].country == "Ethiopia")
        #expect(item.blendComponents[0].ratio == 65)

        try? FileManager.default.removeItem(at: url)
    }

    @Test func exportCafeCoordinate() throws {
        let card = CoffeeCard(inputMode: .auto)
        let cafe = Cafe(name: "스타벅스", latitude: 37.5665, longitude: 126.9780, address: "서울")
        card.cafe = cafe

        let url = try CardExporter.exportJSON([card])
        let data = try Data(contentsOf: url)
        let payload = try JSONDecoder.iso.decode(CardExportPayload.self, from: data)

        let item = try #require(payload.cards.first)
        #expect(item.cafeName == "스타벅스")
        #expect(item.cafeLatitude == 37.5665)
        #expect(item.cafeLongitude == 126.9780)

        try? FileManager.default.removeItem(at: url)
    }
}

extension JSONDecoder {
    static let iso: JSONDecoder = {
        let d = JSONDecoder()
        d.dateDecodingStrategy = .iso8601
        return d
    }()
}
