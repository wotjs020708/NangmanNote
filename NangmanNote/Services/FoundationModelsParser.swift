import Foundation
import FoundationModels
import OSLog

actor FoundationModelsParser {
    private var session: LanguageModelSession?

    /// W1 본 스파이크에서 검증된 instructions.
    /// 한국어/영어 혼재 OCR 텍스트에서 카드 정보를 추출.
    private static let instructions = """
    스페셜티 커피 컵 노트 카드에서 정보를 추출합니다.
    입력은 한국어/영어 혼재 OCR 텍스트로, 카드의 큰 글씨가 단어 단위로 깨져 있을 수 있습니다.
    본문 텍스트에 정확한 정보가 들어있는 경우가 많으니, 본문에서 의미를 해석하세요.

    [블렌드 vs 단일 원두]
    - 블렌드: 2개 이상의 원두가 비율(% / Ratio)과 함께 명시된 경우.
      예: "ETHIOPIA GUJI ... RED HONEY 65% / COLOMBIA ... WASHED 35%"
    - 단일 원두: 산지 + 품종 + 가공이 한 줄 또는 라벨 형식으로 나오는 경우.
      예: "온두라스 로스 아라야네스 / 게이샤 워시드 / 약배전"

    [블렌드 카드 처리]
    - blendName: 본문에서 "'XXX' 블렌드는…" 패턴 또는 큰 글씨로 등장하는 블렌드 상품명.
    - blendComponents: 각 원두를 ParsedBlendComponent로 채움 (country, region?, variety?, process?, ratio?).
    - 단일 원두 필드(originCountry, originRegion, variety, process)는 nil로 둠.

    [단일 원두 카드 처리]
    - originCountry: 국가명만 (Ethiopia, 온두라스, Colombia 등).
    - originRegion: 농장·지역명 (로스 아라야네스, Yirgacheffe Worka Nenke).
    - variety: 품종 (Geisha, 게이샤, Heirloom). 워시드/내추럴은 가공이지 품종이 아님.
    - process: 영문 소문자 (washed, natural, honey, anaerobic, redHoney).
      · 한국어/영문 매핑: 워시드·Fully Washed·Washed → "washed",
        내추럴 → "natural", 허니 → "honey",
        무산소발효 → "anaerobic", 레드허니·Red Honey → "redHoney".
    - blendName, blendComponents는 nil/빈배열.

    [공통]
    - roastLevel: 영문 소문자 (light, mediumLight, medium, mediumDark, dark).
      · 한국어: 약배전 → "light" (절대 "about"이 아님!),
        중약·중약배전 → "mediumLight", 중배전 → "medium",
        중강·중강배전 → "mediumDark", 강배전·풀시티·다크 → "dark".
    - tastingNotes: 향미 단어/구만 추출 (Jasmine, 플로럴, 감귤, Caramel, 꿀).
      긴 묘사 문장은 제외.
    - cafeName: 카페·로스터리 상호명. 농장명·지역명·산지명은 절대 cafeName이 아님.
    - 모호한 필드는 nil.
    - 한국어/영어 혼재 텍스트 그대로 처리.

    [예시 1 — 단일 원두]
    입력 텍스트: "온두라스 로스 아라야네스 / 게이샤 워시드 / 약배전 / 컵 노트: 플로럴, 감귤, 카모마일, 꿀"
    출력:
      blendName: null
      originCountry: "온두라스"
      originRegion: "로스 아라야네스"
      variety: "게이샤"
      process: "washed"
      roastLevel: "light"
      tastingNotes: ["플로럴","감귤","카모마일","꿀"]
      blendComponents: []

    [예시 2 — 블렌드]
    입력 텍스트: "BBINGTIGER X DEFAULT VALUE / '이런 편안한 휴식, 얼마나 오렌지' 블렌드는 … / ETHIOPIA GUJI URAGA TABE HARO WACHU RED HONEY 65% / COLOMBIA JOSE MENESES CM MANDRIN WASHED 35%"
    출력:
      blendName: "이런 편안한 휴식, 얼마나 오렌지"
      originCountry: null
      originRegion: null
      variety: null
      process: null
      blendComponents:
        - { country: "Ethiopia", region: "Guji Uraga Tabe Haro Wachu", variety: null, process: "redHoney", ratio: 65 }
        - { country: "Colombia", region: "Jose Meneses CM Mandrin", variety: null, process: "washed", ratio: 35 }
    """

    enum AvailabilityCheck {
        case ready
        case unavailable(String)
    }

    func availability() -> AvailabilityCheck {
        let status = SystemLanguageModel.default.availability
        switch status {
        case .available:
            return .ready
        case .unavailable(let reason):
            return .unavailable(String(describing: reason))
        @unknown default:
            return .unavailable("unknown")
        }
    }

    func parse(ocrText: String) async throws -> ParsedCupNoteCard {
        if case .unavailable(let reason) = availability() {
            Logger.parsing.error("Foundation Models unavailable: \(reason, privacy: .public)")
            throw ParsingError.modelUnavailable
        }

        if session == nil {
            session = LanguageModelSession(instructions: { Self.instructions })
        }

        guard let session else {
            throw ParsingError.modelUnavailable
        }

        do {
            let response = try await session.respond(
                to: ocrText,
                generating: ParsedCupNoteCard.self
            )
            return response.content
        } catch {
            Logger.parsing.error("LanguageModelSession.respond failed: \(error.localizedDescription, privacy: .public)")
            throw ParsingError.decodingFailed
        }
    }
}
