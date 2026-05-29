import Testing
import SwiftData
import Foundation
@testable import NangmanNote

@MainActor
struct BlendComponentTests {
    private func makeContainer() throws -> ModelContainer {
        try ModelContainer(
            for: CoffeeCard.self, Cafe.self, TastingNote.self, BlendComponent.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    @Test func insertAndFetch() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let comp = BlendComponent(
            country: "Ethiopia",
            region: "Guji",
            variety: "Heirloom",
            process: .redHoney,
            ratio: 65
        )
        context.insert(comp)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<BlendComponent>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.country == "Ethiopia")
        #expect(fetched.first?.ratio == 65)
        #expect(fetched.first?.process == .redHoney)
    }

    @Test func processRawRoundtrip() {
        let comp = BlendComponent(country: "Colombia", process: .washed, ratio: 35)
        #expect(comp.processRaw == "washed")
        #expect(comp.process == .washed)

        comp.process = .natural
        #expect(comp.processRaw == "natural")
    }

    @Test func summaryFormatting() {
        let comp = BlendComponent(
            country: "Ethiopia",
            variety: "Heirloom",
            process: .redHoney,
            ratio: 65
        )
        #expect(comp.summary.contains("Ethiopia"))
        #expect(comp.summary.contains("Heirloom"))
        #expect(comp.summary.contains("redHoney"))
        #expect(comp.summary.contains("65%"))
    }

    @Test func summaryWithMinimalFields() {
        let comp = BlendComponent(country: "Colombia")
        #expect(comp.summary == "Colombia")
    }

    @Test func cascadeDeleteFromCard() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let card = CoffeeCard()
        card.blendName = "Test Blend"

        let comp1 = BlendComponent(country: "Ethiopia", process: .redHoney, ratio: 65)
        let comp2 = BlendComponent(country: "Colombia", process: .washed, ratio: 35)
        comp1.card = card
        comp2.card = card
        card.blendComponents.append(comp1)
        card.blendComponents.append(comp2)

        context.insert(card)
        context.insert(comp1)
        context.insert(comp2)
        try context.save()

        #expect(try context.fetch(FetchDescriptor<BlendComponent>()).count == 2)
        #expect(card.blendComponents.count == 2)

        context.delete(card)
        try context.save()

        #expect(try context.fetch(FetchDescriptor<CoffeeCard>()).isEmpty)
        #expect(try context.fetch(FetchDescriptor<BlendComponent>()).isEmpty)
    }
}
