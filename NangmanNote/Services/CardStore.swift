import Foundation
import SwiftData

@MainActor
@Observable
final class CardStore {
    private(set) var cards: [CoffeeCard] = []
    private let context: ModelContext

    init(context: ModelContext) {
        self.context = context
        refresh()
    }

    func refresh() {
        let descriptor = FetchDescriptor<CoffeeCard>(
            sortBy: [SortDescriptor(\.capturedAt, order: .reverse)]
        )
        cards = (try? context.fetch(descriptor)) ?? []
    }

    func add(_ card: CoffeeCard) {
        context.insert(card)
        try? context.save()
        refresh()
    }

    func delete(_ card: CoffeeCard) {
        context.delete(card)
        try? context.save()
        refresh()
    }
}
