import Foundation
import SwiftData

@Model
final class TastingNote {
    @Attribute(.unique) var id: UUID
    var label: String
    var categoryRaw: String

    var cards: [CoffeeCard] = []

    init(
        id: UUID = UUID(),
        label: String,
        category: NoteCategory = .other
    ) {
        self.id = id
        self.label = label
        self.categoryRaw = category.rawValue
    }

    var category: NoteCategory {
        get { NoteCategory(rawValue: categoryRaw) ?? .other }
        set { categoryRaw = newValue.rawValue }
    }
}
