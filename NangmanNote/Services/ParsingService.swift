import Foundation
import Observation

enum ParsingError: Error, LocalizedError {
    case modelUnavailable
    case decodingFailed
    case empty

    var errorDescription: String? {
        switch self {
        case .modelUnavailable: "AI 모델을 사용할 수 없습니다."
        case .decodingFailed: "결과를 해석하지 못했습니다."
        case .empty: "인식할 텍스트가 없습니다."
        }
    }
}

/// M1.2 (#2)에서 Foundation Models 기반으로 교체. 현재는 Mock 구현.
@Observable
@MainActor
final class ParsingService: ParsingServicing {
    private(set) var isParsing = false
    private(set) var lastError: ParsingError?

    init() {}

    func parse(ocrText: String) async throws -> ParsedCupNoteCard {
        isParsing = true
        defer { isParsing = false }
        lastError = nil

        // 처리 시뮬레이션
        try? await Task.sleep(nanoseconds: 700_000_000)

        let trimmed = ocrText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            lastError = .empty
            throw ParsingError.empty
        }

        // Mock 키워드 매칭 — M1.2 #2에서 @Generable + LanguageModelSession으로 교체
        let lower = trimmed.lowercased()
        let isBlend = lower.contains("blend") || trimmed.contains("블렌드") || trimmed.contains("X ")

        let countryHint: String? = {
            if trimmed.contains("Ethiopia") || trimmed.contains("에티오피아") { return "Ethiopia" }
            if trimmed.contains("Honduras") || trimmed.contains("온두라스") { return "Honduras" }
            if trimmed.contains("Colombia") || trimmed.contains("콜롬비아") { return "Colombia" }
            if trimmed.contains("Kenya") || trimmed.contains("케냐") { return "Kenya" }
            return nil
        }()

        let blendName: String? = isBlend ? trimmed.split(separator: "\n").first.map { String($0) } : nil

        return ParsedCupNoteCard(
            blendName: blendName,
            originCountry: isBlend ? nil : countryHint,
            originRegion: nil,
            variety: nil,
            process: nil,
            roastLevel: nil,
            tastingNotes: [],
            cafeName: nil
        )
    }

    /// 코드 계산 신뢰도: OCR 평균 신뢰도 * 0.6 + 핵심 필드 충족률 * 0.4
    func computeConfidence(ocr: [OCRBlock], parsed: ParsedCupNoteCard) -> Double {
        let ocrAvg: Double = ocr.isEmpty
            ? 0
            : Double(ocr.map(\.confidence).reduce(0, +)) / Double(ocr.count)

        let critical: [Any?] = [
            parsed.blendName ?? parsed.originCountry,
            parsed.tastingNotes.first
        ]
        let filled = Double(critical.compactMap { $0 }.count)
        let total = Double(critical.count)
        let filledRatio = total > 0 ? filled / total : 0

        return ocrAvg * 0.6 + filledRatio * 0.4
    }
}

struct MockParsingService: ParsingServicing {
    let fixedResult: ParsedCupNoteCard

    init(fixedResult: ParsedCupNoteCard = ParsedCupNoteCard(tastingNotes: [])) {
        self.fixedResult = fixedResult
    }

    func parse(ocrText: String) async throws -> ParsedCupNoteCard {
        fixedResult
    }
}
