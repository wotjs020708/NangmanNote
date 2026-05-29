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

/// M1.2 (#2)에서 Foundation Models 기반으로 교체. 현재는 패턴 매칭 강화 Mock.
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

        try? await Task.sleep(nanoseconds: 500_000_000)

        let trimmed = ocrText.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmed.isEmpty {
            lastError = .empty
            throw ParsingError.empty
        }

        return Self.parseHeuristic(trimmed)
    }

    /// 패턴 매칭으로 카드 정보 추출. 실제 Foundation Models 교체 전까지 사용.
    /// 알려진 한계: 디자인 폰트로 깨진 큰 글씨는 못 잡음 (LLM이 본문에서 해석해야 함).
    static func parseHeuristic(_ text: String) -> ParsedCupNoteCard {
        // 1) 블렌드 이름
        let blendName = extractBlendName(from: text)

        // 2) 블렌드 컴포넌트
        let componentMatches = extractBlendComponents(from: text)
        let parsedComponents: [ParsedBlendComponent] = componentMatches.map { match in
            ParsedBlendComponent(
                country: match.country,
                region: nil,
                variety: nil,
                process: match.process,
                ratio: match.ratio
            )
        }
        let isBlend = blendName != nil || parsedComponents.count >= 2

        // 3) 단일 원두 분기
        var originCountry: String?
        var originRegion: String?
        var variety: String?
        var process: String?

        if !isBlend {
            originCountry = extractCountry(from: text)
            originRegion = extractRegionAfterCountry(from: text, country: originCountry)
            variety = extractVariety(from: text)
        }

        // 4) 가공: 블렌드여도 본문에 명시되면 채움 (단일 카드의 process 필드용)
        if process == nil && !isBlend {
            process = extractProcess(from: text)
        }

        // 5) 로스팅
        let roastLevel = extractRoastLevel(from: text)

        // 6) 테이스팅 노트
        let tastingNotes = extractTastingNotes(from: text)

        return ParsedCupNoteCard(
            blendName: blendName,
            originCountry: originCountry,
            originRegion: originRegion,
            variety: variety,
            process: process,
            roastLevel: roastLevel,
            tastingNotes: tastingNotes,
            cafeName: nil,
            blendComponents: parsedComponents
        )
    }

    // MARK: - 패턴 추출

    private static let quotePairs: [(String, String)] = [("'", "'"), ("'", "'"), ("\"", "\"")]

    private static func extractBlendName(from text: String) -> String? {
        // "'XXX' 블렌드" 또는 'XXX' 블렌드는
        for (open, close) in quotePairs {
            let pattern = "\(open)([^\(close)]+?)\(close)\\s*블렌드"
            if let regex = try? NSRegularExpression(pattern: pattern),
               let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
               let range = Range(match.range(at: 1), in: text) {
                let name = String(text[range]).trimmingCharacters(in: .whitespacesAndNewlines)
                if !name.isEmpty { return name }
            }
        }
        // 가짜 따옴표 없이 "XXX 블렌드는"
        let plain = #"([\p{L}\s,·]+?)\s*블렌드[는은이가]"#
        if let regex = try? NSRegularExpression(pattern: plain),
           let match = regex.firstMatch(in: text, range: NSRange(text.startIndex..., in: text)),
           let range = Range(match.range(at: 1), in: text) {
            let candidate = String(text[range])
                .trimmingCharacters(in: .whitespacesAndNewlines)
            // 너무 짧거나 너무 긴 후보 제외
            if candidate.count >= 4 && candidate.count <= 40 {
                return candidate
            }
        }
        return nil
    }

    struct BlendComponentMatch {
        let country: String
        let process: String?
        let ratio: Int?
    }

    private static let processKeywords: [(pattern: String, normalized: String)] = [
        ("RED HONEY", "redHoney"),
        ("YELLOW HONEY", "honey"),
        ("BLACK HONEY", "honey"),
        ("FULLY WASHED", "washed"),
        ("WASHED", "washed"),
        ("NATURAL", "natural"),
        ("ANAEROBIC", "anaerobic"),
        ("HONEY", "honey"),
        ("워시드", "washed"),
        ("내추럴", "natural"),
        ("허니", "honey"),
        ("무산소", "anaerobic")
    ]

    private static func extractBlendComponents(from text: String) -> [BlendComponentMatch] {
        // "COUNTRY ... PROCESS NN%" 형식의 한 줄
        var results: [BlendComponentMatch] = []
        let lines = text.split(separator: "\n").map(String.init)
        let countries = ["ETHIOPIA", "COLOMBIA", "HONDURAS", "KENYA", "BRAZIL", "GUATEMALA", "PANAMA", "RWANDA", "PERU", "MEXICO", "EL SALVADOR", "COSTA RICA", "TANZANIA"]

        for line in lines {
            let upper = line.uppercased()
            guard let country = countries.first(where: { upper.contains($0) }) else { continue }

            // 가공 키워드 찾기 (긴 패턴부터)
            let process = processKeywords.first(where: { upper.contains($0.pattern.uppercased()) })?.normalized

            // 비율 NN% 추출
            let ratioPattern = #"(\d{1,3})\s*%"#
            var ratio: Int?
            if let regex = try? NSRegularExpression(pattern: ratioPattern),
               let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
               let range = Range(match.range(at: 1), in: line) {
                ratio = Int(line[range])
            }

            if ratio != nil || process != nil {
                results.append(BlendComponentMatch(country: country.capitalized, process: process, ratio: ratio))
            }
        }
        return results
    }

    private static let countryAliases: [(canonical: String, aliases: [String])] = [
        ("Ethiopia", ["Ethiopia", "에티오피아"]),
        ("Honduras", ["Honduras", "온두라스"]),
        ("Colombia", ["Colombia", "콜롬비아"]),
        ("Kenya", ["Kenya", "케냐"]),
        ("Brazil", ["Brazil", "브라질"]),
        ("Guatemala", ["Guatemala", "과테말라"]),
        ("Costa Rica", ["Costa Rica", "코스타리카"]),
        ("Panama", ["Panama", "파나마"]),
        ("Rwanda", ["Rwanda", "르완다"]),
        ("Burundi", ["Burundi", "부룬디"]),
        ("El Salvador", ["El Salvador", "엘살바도르"]),
        ("Nicaragua", ["Nicaragua", "니카라과"]),
        ("Peru", ["Peru", "페루"]),
        ("Mexico", ["Mexico", "멕시코"]),
        ("Tanzania", ["Tanzania", "탄자니아"]),
        ("Indonesia", ["Indonesia", "인도네시아"]),
        ("Yemen", ["Yemen", "예멘"])
    ]

    private static func extractCountry(from text: String) -> String? {
        for (canonical, aliases) in countryAliases {
            for alias in aliases where text.range(of: alias, options: .caseInsensitive) != nil {
                return canonical
            }
        }
        return nil
    }

    private static func extractRegionAfterCountry(from text: String, country: String?) -> String? {
        // 한국어 카드: "온두라스 로스 아라야네스 / 게이샤 워시드"
        // 영어 카드: 라벨 형식 "Farm: Yirgacheffe Worka Nenke"
        guard let _ = country else { return nil }
        let knownRegions = ["Yirgacheffe", "Worka", "Nenke", "Guji", "Sidamo", "Huehuetenango", "Antigua", "Tarrazu", "로스 아라야네스", "예가체프"]
        for region in knownRegions where text.range(of: region, options: .caseInsensitive) != nil {
            return region
        }
        return nil
    }

    private static let varietyKeywords = ["Geisha", "게이샤", "Heirloom", "Bourbon", "Typica", "Caturra", "Pacamara", "SL28", "SL34", "Catimor", "Mundo Novo"]

    private static func extractVariety(from text: String) -> String? {
        for v in varietyKeywords where text.range(of: v, options: .caseInsensitive) != nil {
            return v
        }
        return nil
    }

    private static func extractProcess(from text: String) -> String? {
        let upper = text.uppercased()
        for (pattern, normalized) in processKeywords where upper.contains(pattern.uppercased()) {
            return normalized
        }
        return nil
    }

    private static func extractRoastLevel(from text: String) -> String? {
        if text.contains("약배전") || text.range(of: "Light Roast", options: .caseInsensitive) != nil { return "light" }
        if text.contains("중강배전") || text.range(of: "Medium Dark", options: .caseInsensitive) != nil { return "mediumDark" }
        if text.contains("중약배전") || text.range(of: "Medium Light", options: .caseInsensitive) != nil { return "mediumLight" }
        if text.contains("중배전") || text.range(of: "Medium Roast", options: .caseInsensitive) != nil { return "medium" }
        if text.contains("강배전") || text.range(of: "Dark Roast", options: .caseInsensitive) != nil { return "dark" }
        return nil
    }

    private static let noteKeywords = [
        "Jasmine", "Blueberry", "Citrus", "Apricot", "Cane Sugar", "Caramel",
        "Chocolate", "Dark Chocolate", "Strawberry", "Peach", "Floral", "Bergamot",
        "Honey", "Vanilla", "Almond", "Hazelnut", "Maple",
        "자스민", "블루베리", "감귤", "오렌지", "캐러멜", "초콜릿", "딸기", "복숭아",
        "플로럴", "베르가못", "카모마일", "꿀", "바닐라"
    ]

    private static func extractTastingNotes(from text: String) -> [String] {
        var notes: [String] = []
        for note in noteKeywords where text.range(of: note, options: .caseInsensitive) != nil {
            if !notes.contains(where: { $0.compare(note, options: .caseInsensitive) == .orderedSame }) {
                notes.append(note)
            }
        }
        return notes
    }

    /// 코드 계산 신뢰도
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
