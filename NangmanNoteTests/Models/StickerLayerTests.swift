import Testing
import SwiftData
import Foundation
@testable import NangmanNote

@MainActor
struct StickerLayerTests {
    private func makeContainer() throws -> ModelContainer {
        try ModelContainer(
            for: CoffeeCard.self, Cafe.self, TastingNote.self, BlendComponent.self,
                TextLayer.self, StickerLayer.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    @Test func insertAndFetch() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let sticker = StickerLayer(emoji: "☕", positionX: 0.3, positionY: 0.7)
        context.insert(sticker)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<StickerLayer>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.emoji == "☕")
        #expect(fetched.first?.positionX == 0.3)
    }

    @Test func paletteHas12Emojis() {
        #expect(StickerPreset.palette.count == 12)
        #expect(StickerPreset.palette.contains("☕"))
        #expect(StickerPreset.palette.contains("💜"))
        #expect(StickerPreset.palette.contains("🌸"))
    }

    @Test func cascadeDeleteFromCard() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let card = CoffeeCard()
        let s1 = StickerLayer(emoji: "☕")
        let s2 = StickerLayer(emoji: "🌸")
        s1.card = card; s2.card = card
        card.stickerLayers = [s1, s2]
        context.insert(card)
        context.insert(s1)
        context.insert(s2)
        try context.save()

        #expect(try context.fetch(FetchDescriptor<StickerLayer>()).count == 2)

        context.delete(card)
        try context.save()

        #expect(try context.fetch(FetchDescriptor<StickerLayer>()).isEmpty)
    }
}
