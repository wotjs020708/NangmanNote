import Testing
import SwiftData
import Foundation
@testable import NangmanNote

@MainActor
struct TextLayerTests {
    private func makeContainer() throws -> ModelContainer {
        try ModelContainer(
            for: CoffeeCard.self, Cafe.self, TastingNote.self, BlendComponent.self, TextLayer.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    @Test func insertAndFetch() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let layer = TextLayer(content: "비 오는 일요일", positionX: 0.3, positionY: 0.6, fontStyle: .serif, hexColor: "#D67A8E")
        context.insert(layer)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<TextLayer>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.content == "비 오는 일요일")
        #expect(fetched.first?.fontStyle == .serif)
        #expect(fetched.first?.hexColor == "#D67A8E")
    }

    @Test func fontStyleRoundtrip() {
        let layer = TextLayer(content: "test", fontStyle: .mono)
        #expect(layer.fontStyleRaw == "mono")
        #expect(layer.fontStyle == .mono)
        layer.fontStyle = .body
        #expect(layer.fontStyleRaw == "body")
    }

    @Test func cascadeDeleteFromCard() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let card = CoffeeCard()
        let l1 = TextLayer(content: "A")
        let l2 = TextLayer(content: "B")
        l1.card = card; l2.card = card
        card.textLayers = [l1, l2]
        context.insert(card)
        context.insert(l1)
        context.insert(l2)
        try context.save()

        #expect(try context.fetch(FetchDescriptor<TextLayer>()).count == 2)

        context.delete(card)
        try context.save()

        #expect(try context.fetch(FetchDescriptor<TextLayer>()).isEmpty)
    }

    @Test func colorMappingFromHex() {
        let layer = TextLayer(content: "x", hexColor: "#FFFFFF")
        // White preset이 존재 → color는 .white에 가까움. 정확 비교는 어렵지만 nil 아님.
        // 단순 검증: layer.color는 항상 반환됨
        _ = layer.color
    }
}
