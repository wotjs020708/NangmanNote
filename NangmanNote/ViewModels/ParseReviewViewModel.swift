import Foundation
import UIKit
import Observation
import OSLog

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

    // 디버그 노출용
    var ocrRawText: String = ""
    var ocrBlockCount: Int = 0
    var ocrAvgConfidence: Double = 0

    // 카드 유형 (자동 감지 → 사용자 override 가능)
    var isBlend: Bool = false

    // 단일 원두 필드
    var blendName: String = ""
    var originCountry: String = ""
    var originRegion: String = ""
    var variety: String = ""
    var process: String = ""
    var roastLevel: String = ""
    var tastingNotesText: String = ""
    var cafeName: String = ""

    // 블렌드 컴포넌트
    var blendComponents: [ParsedBlendComponent] = []

    // 사용자 기록
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
                Logger.ocr.error("ImagePreprocessor returned nil")
                stage = .failed("이미지 전처리 실패")
                return
            }
            processedImage = UIImage(cgImage: processed)

            let blocks = try await ocr.recognize(processed)
            let text = blocks.joinedText()
            let avg: Double = blocks.isEmpty
                ? 0
                : Double(blocks.map(\.confidence).reduce(0, +)) / Double(blocks.count)

            ocrRawText = text
            ocrBlockCount = blocks.count
            ocrAvgConfidence = avg

            Logger.ocr.info("OCR done — blocks=\(blocks.count, privacy: .public), avgConfidence=\(String(format: "%.2f", avg), privacy: .public), textLen=\(text.count, privacy: .public)")
            Logger.ocr.debug("OCR text: \(text, privacy: .public)")

            Logger.parsing.info("Parser invoked with text (first 200 chars): \(text.prefix(200), privacy: .public)")
            let parsed = try await parser.parse(ocrText: text)
            Logger.parsing.info("Parser result — isBlend=\(parsed.isBlend, privacy: .public), blendName=\(parsed.blendName ?? "nil", privacy: .public), components=\(parsed.blendComponents.count, privacy: .public), tastingNotes=\(parsed.tastingNotes.joined(separator: ", "), privacy: .public)")

            if let service = parser as? ParsingService {
                confidence = service.computeConfidence(ocr: blocks, parsed: parsed)
            } else {
                confidence = 0.6
            }

            applyParsed(parsed)
            stage = .ready
        } catch {
            Logger.parsing.error("Pipeline failed: \(error.localizedDescription, privacy: .public)")
            stage = .failed(error.localizedDescription)
        }
    }

    private func applyParsed(_ parsed: ParsedCupNoteCard) {
        isBlend = parsed.isBlend
        blendName = parsed.blendName ?? ""
        originCountry = parsed.originCountry ?? ""
        originRegion = parsed.originRegion ?? ""
        variety = parsed.variety ?? ""
        process = parsed.process ?? ""
        roastLevel = parsed.roastLevel ?? ""
        tastingNotesText = parsed.tastingNotes.joined(separator: ", ")
        cafeName = parsed.cafeName ?? ""
        blendComponents = parsed.blendComponents
    }

    @discardableResult
    func save() -> Bool {
        guard case .ready = stage else { return false }

        let card = CoffeeCard(backImagePath: "", inputMode: .auto)

        if isBlend {
            card.blendName = nilIfEmpty(blendName)
            // 단일 원두 필드는 비움 (블렌드 카드)
            for comp in blendComponents {
                let bc = BlendComponent(
                    country: comp.country,
                    region: comp.region,
                    variety: comp.variety,
                    process: comp.process.flatMap(ProcessMethod.init(rawValue:)),
                    ratio: comp.ratio
                )
                bc.card = card
                card.blendComponents.append(bc)
            }
        } else {
            // 단일 원두
            card.originCountry = nilIfEmpty(originCountry)
            card.originRegion = nilIfEmpty(originRegion)
            card.variety = nilIfEmpty(variety)
            card.processRaw = nilIfEmpty(process)
        }

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
