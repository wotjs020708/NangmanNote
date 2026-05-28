import Testing
import SwiftData
import CoreLocation
import Foundation
@testable import NangmanNote

@MainActor
struct CafeTests {
    private func makeContainer() throws -> ModelContainer {
        try ModelContainer(
            for: CoffeeCard.self, Cafe.self, TastingNote.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
    }

    @Test func coordinateNilIfBothMissing() {
        let cafe = Cafe(name: "테스트 카페")
        #expect(cafe.coordinate == nil)
    }

    @Test func coordinateNilIfOnlyLatitude() {
        let cafe = Cafe(name: "테스트", latitude: 37.5)
        #expect(cafe.coordinate == nil)
    }

    @Test func coordinateValid() {
        let cafe = Cafe(name: "테스트", latitude: 37.5665, longitude: 126.9780)
        let coord = cafe.coordinate
        #expect(coord != nil)
        #expect(coord?.latitude == 37.5665)
        #expect(coord?.longitude == 126.9780)
    }

    @Test func insertWithMultipleCards() throws {
        let container = try makeContainer()
        let context = ModelContext(container)

        let cafe = Cafe(name: "스타벅스")
        let card1 = CoffeeCard()
        let card2 = CoffeeCard()
        card1.cafe = cafe
        card2.cafe = cafe

        context.insert(cafe)
        context.insert(card1)
        context.insert(card2)
        try context.save()

        let fetched = try context.fetch(FetchDescriptor<Cafe>())
        #expect(fetched.count == 1)
        #expect(fetched.first?.cards.count == 2)
    }
}
