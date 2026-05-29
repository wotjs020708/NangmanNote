import Foundation
import UIKit
import Observation

@Observable
@MainActor
final class ManualEntryViewModel {
    let originalImage: UIImage

    var isBlend = false
    var blendName = ""
    var originCountry = ""
    var originRegion = ""
    var variety = ""
    var process = ""
    var roastLevel = ""
    var tastingNotesText = ""
    var cafeName = ""

    var userMemo = ""
    var userRating = 0

    private let cardStore: CardStore

    init(image: UIImage, cardStore: CardStore) {
        self.originalImage = image
        self.cardStore = cardStore
    }

    @discardableResult
    func save() -> Bool {
        let card = CoffeeCard(backImagePath: "", inputMode: .manual)

        if isBlend {
            card.blendName = nilIfEmpty(blendName)
        } else {
            card.originCountry = nilIfEmpty(originCountry)
            card.originRegion = nilIfEmpty(originRegion)
            card.variety = nilIfEmpty(variety)
        }
        card.processRaw = nilIfEmpty(process)
        card.roastLevelRaw = nilIfEmpty(roastLevel)
        card.userMemo = nilIfEmpty(userMemo)
        card.userRating = userRating > 0 ? userRating : nil

        if let trimmedCafe = nilIfEmpty(cafeName) {
            card.cafe = Cafe(name: trimmedCafe)
        }

        cardStore.add(card)
        return true
    }

    private func nilIfEmpty(_ s: String) -> String? {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
