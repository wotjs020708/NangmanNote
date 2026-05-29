import Foundation
import UIKit
import Observation

@Observable
@MainActor
final class ParseReviewViewModel {
    enum Stage: Equatable {
        case processing
        case ready
        case failed(String)
    }

    let originalImage: UIImage
    var stage: Stage = .processing
    var processedImage: UIImage?
    var confidence: Double = 0

    var blendName: String = ""
    var originCountry: String = ""
    var originRegion: String = ""
    var variety: String = ""
    var process: String = ""
    var roastLevel: String = ""
    var tastingNotesText: String = ""
    var cafeName: String = ""

    var userMemo: String = ""
    var userRating: Int = 0

    private let preprocessor: ImagePreprocessor
    private let ocr: OCRServicing
    private let parser: ParsingServicing
    private let cardStore: CardStore

    init(
        image: UIImage,
        preprocessor: ImagePreprocessor,
        ocr: OCRServicing,
        parser: ParsingServicing,
        cardStore: CardStore
    ) {
        self.originalImage = image
        self.preprocessor = preprocessor
        self.ocr = ocr
        self.parser = parser
        self.cardStore = cardStore
    }

    func start() async {
        stage = .processing
        do {
            guard let processed = await preprocessor.process(originalImage) else {
                stage = .failed("이미지 전처리 실패")
                return
            }
            processedImage = UIImage(cgImage: processed)

            let blocks = try await ocr.recognize(processed)
            let text = blocks.joinedText()

            let parsed = try await parser.parse(ocrText: text)

            if let service = parser as? ParsingService {
                confidence = service.computeConfidence(ocr: blocks, parsed: parsed)
            } else {
                confidence = 0.6
            }

            applyParsed(parsed)
            stage = .ready
        } catch {
            stage = .failed(error.localizedDescription)
        }
    }

    private func applyParsed(_ parsed: ParsedCupNoteCard) {
        blendName = parsed.blendName ?? ""
        originCountry = parsed.originCountry ?? ""
        originRegion = parsed.originRegion ?? ""
        variety = parsed.variety ?? ""
        process = parsed.process ?? ""
        roastLevel = parsed.roastLevel ?? ""
        tastingNotesText = parsed.tastingNotes.joined(separator: ", ")
        cafeName = parsed.cafeName ?? ""
    }

    @discardableResult
    func save() -> Bool {
        guard case .ready = stage else { return false }

        let card = CoffeeCard(backImagePath: "", inputMode: .auto)
        card.blendName = nilIfEmpty(blendName)
        card.originCountry = nilIfEmpty(originCountry)
        card.originRegion = nilIfEmpty(originRegion)
        card.variety = nilIfEmpty(variety)
        card.processRaw = nilIfEmpty(process)
        card.roastLevelRaw = nilIfEmpty(roastLevel)
        card.userMemo = nilIfEmpty(userMemo)
        card.userRating = userRating > 0 ? userRating : nil
        card.parsingConfidence = confidence

        cardStore.add(card)
        return true
    }

    private func nilIfEmpty(_ s: String) -> String? {
        let trimmed = s.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
