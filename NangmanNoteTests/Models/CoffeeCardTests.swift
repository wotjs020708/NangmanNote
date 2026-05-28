import Testing
import SwiftData
import Foundation
@testable import NangmanNote

@MainActor
struct CoffeeCardTests {
    private func makeContainer() throws -> ModelContainer {
        try ModelContainer(
            for: CoffeeCard.self, Cafe.self, TastingNote.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    @Test func insertAndFetch() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let card = CoffeeCard(backImagePath: "test.jpg")
        card.originCountry = "온두라스"
        card.originRegion = "로스 아라야네스"
        card.variety = "게이샤"
        context.insert(card)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<CoffeeCard>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.originCountry == "온두라스")
        #expect(fetched.first?.variety == "게이샤")
        #expect(fetched.first?.backImagePath == "test.jpg")
    }

    @Test func displayNameSingleOrigin() {
        let card = CoffeeCard()
        card.originCountry = "Ethiopia"
        card.originRegion = "Yirgacheffe"
        card.variety = "Heirloom"
        #expect(card.displayName == "Ethiopia Yirgacheffe Heirloom")
    }

    @Test func displayNameBlend() {
        let card = CoffeeCard()
        card.blendName = "BBINGTIGER X DEFAULT VALUE"
        #expect(card.displayName == "BBINGTIGER X DEFAULT VALUE")
    }

    @Test func displayNameEmpty() {
        let card = CoffeeCard()
        #expect(card.displayName == "이름 없음")
    }

    @Test func displayNamePartialFields() {
        let card = CoffeeCard()
        card.originCountry = "Honduras"
        #expect(card.displayName == "Honduras")
    }

    @Test func processRoastEnumRoundtrip() {
        let card = CoffeeCard()
        card.process = .washed
        card.roastLevel = .light
        #expect(card.processRaw == "washed")
        #expect(card.roastLevelRaw == "light")
        #expect(card.process == .washed)
        #expect(card.roastLevel == .light)
    }

    @Test func inputModeRoundtrip() {
        let card = CoffeeCard(inputMode: .manual)
        #expect(card.inputModeRaw == "manual")
        #expect(card.inputMode == .manual)
        card.inputMode = .auto
        #expect(card.inputModeRaw == "auto")
        #expect(card.inputMode == .auto)
    }
}
