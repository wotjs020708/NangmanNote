import Testing
import SwiftData
import Foundation
@testable import NangmanNote

@MainActor
struct TastingNoteTests {
    private func makeContainer() throws -> ModelContainer {
        try ModelContainer(
            for: CoffeeCard.self, Cafe.self, TastingNote.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    @Test func categoryRoundtrip() {
        let note = TastingNote(label: "Jasmine", category: .floral)
        #expect(note.categoryRaw == "floral")
        #expect(note.category == .floral)

        note.category = .fruit
        #expect(note.categoryRaw == "fruit")
    }

    @Test func defaultCategoryIsOther() {
        let note = TastingNote(label: "Unknown")
        #expect(note.category == .other)
    }

    @Test func manyToManyWithCards() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let note = TastingNote(label: "Blueberry", category: .fruit)
        let card1 = CoffeeCard()
        let card2 = CoffeeCard()
        card1.tastingNotes.append(note)
        card2.tastingNotes.append(note)

        context.insert(note)
        context.insert(card1)
        context.insert(card2)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<TastingNote>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.cards.count == 2)
    }
}
