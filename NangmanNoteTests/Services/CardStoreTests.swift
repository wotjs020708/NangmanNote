import Testing
import SwiftData
import Foundation
@testable import NangmanNote

@MainActor
struct CardStoreTests {
    private func makeStore() throws -> CardStore {
        let container = try ModelContainer(
            for: CoffeeCard.self, Cafe.self, TastingNote.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return CardStore(context: ModelContext(container))
    }

    @Test func addAndRefresh() throws {
        let store = try makeStore()
        #expect(store.cards.isEmpty)

        let card = CoffeeCard(backImagePath: "a.jpg")
        card.originCountry = "Ethiopia"
        store.add(card)

        #expect(store.cards.count == 1)
        #expect(store.cards.first?.originCountry == "Ethiopia")
    }

    @Test func sortedByCapturedAtDescending() throws {
        let store = try makeStore()
        let now = Date()

        let older = CoffeeCard(capturedAt: now.addingTimeInterval(-3600), backImagePath: "old.jpg")
        let newer = CoffeeCard(capturedAt: now, backImagePath: "new.jpg")

        store.add(older)
        store.add(newer)

        #expect(store.cards.count == 2)
        #expect(store.cards.first?.backImagePath == "new.jpg")
        #expect(store.cards.last?.backImagePath == "old.jpg")
    }

    @Test func deleteCard() throws {
        let store = try makeStore()
        let card = CoffeeCard(backImagePath: "doomed.jpg")
        store.add(card)
        #expect(store.cards.count == 1)

        store.delete(card)
        #expect(store.cards.isEmpty)
    }
}
