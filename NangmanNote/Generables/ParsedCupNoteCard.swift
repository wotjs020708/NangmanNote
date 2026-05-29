import Foundation
import FoundationModels

@Generable
struct ParsedBlendComponent: Sendable, Equatable, Hashable {
    @Guide(description: "산지 국가명. 예: Ethiopia, Colombia, Honduras, Kenya. 한국어로 적혀있어도 영문으로 변환.")
    let country: String

    @Guide(description: "산지 지역·농장. 예: Guji, Yirgacheffe. 없으면 nil.")
    let region: String?

    @Guide(description: "품종. 예: Geisha, Heirloom, Bourbon. 없으면 nil.")
    let variety: String?

    @Guide(description: "가공 방식 영문 소문자: washed, natural, honey, anaerobic, redHoney 중 하나. 없으면 nil.")
    let process: String?

    @Guide(description: "블렌드에서 차지하는 비율 (백분율 정수). 명시되지 않았으면 nil.")
    let ratio: Int?

    init(
        country: String,
        region: String? = nil,
        variety: String? = nil,
        process: String? = nil,
        ratio: Int? = nil
    ) {
        self.country = country
        self.region = region
        self.variety = variety
        self.process = process
        self.ratio = ratio
    }

    var summary: String {
        var parts: [String] = [country]
        if let variety { parts.append(variety) }
        if let process { parts.append(process) }
        if let ratio { parts.append("\(ratio)%") }
        return parts.joined(separator: " · ")
    }
}

@Generable
struct ParsedCupNoteCard: Sendable, Equatable {
    @Guide(description: "블렌드 이름. 단일 원두 카드는 nil. 본문에 \"XXX 블렌드는…\" 같은 패턴으로 등장하면 추출.")
    let blendName: String?

    @Guide(description: "단일 원두 카드의 산지 국가. 블렌드 카드는 nil.")
    let originCountry: String?

    @Guide(description: "단일 원두 카드의 산지 지역·농장명 (예: 로스 아라야네스, Yirgacheffe Worka Nenke). 카페명·로스터리명이 아님.")
    let originRegion: String?

    @Guide(description: "단일 원두 카드의 품종 (예: Geisha, 게이샤, Heirloom, Bourbon). 워시드/내추럴은 가공이지 품종이 아님.")
    let variety: String?

    @Guide(description: "단일 원두 카드의 가공 영문 소문자: washed, natural, honey, anaerobic, redHoney. 한/영 매핑: 워시드→washed, 내추럴→natural, 허니→honey, 무산소발효→anaerobic, 레드허니/Red Honey→redHoney. 블렌드 카드는 nil.")
    let process: String?

    @Guide(description: "로스팅 영문 소문자: light, mediumLight, medium, mediumDark, dark. 한국어 매핑: 약배전→light, 중약→mediumLight, 중→medium, 중강→mediumDark, 강배전/풀시티/다크→dark.")
    let roastLevel: String?

    @Guide(description: "테이스팅 노트 (향미 단어/구). 예: Jasmine, 플로럴, 감귤, Caramel. 긴 묘사 문장은 제외하고 단어/짧은 구만.")
    let tastingNotes: [String]

    @Guide(description: "카페·로스터리 상호명. 농장명·지역명·산지명은 절대 cafeName이 아님.")
    let cafeName: String?

    @Guide(description: "블렌드 카드의 구성 원두 리스트. 카드에 ETHIOPIA … 65%, COLOMBIA … 35% 같이 비율과 함께 명시된 경우만. 단일 원두 카드는 빈 배열.")
    let blendComponents: [ParsedBlendComponent]

    init(
        blendName: String? = nil,
        originCountry: String? = nil,
        originRegion: String? = nil,
        variety: String? = nil,
        process: String? = nil,
        roastLevel: String? = nil,
        tastingNotes: [String] = [],
        cafeName: String? = nil,
        blendComponents: [ParsedBlendComponent] = []
    ) {
        self.blendName = blendName
        self.originCountry = originCountry
        self.originRegion = originRegion
        self.variety = variety
        self.process = process
        self.roastLevel = roastLevel
        self.tastingNotes = tastingNotes
        self.cafeName = cafeName
        self.blendComponents = blendComponents
    }
}

extension ParsedCupNoteCard {
    /// 블렌드 여부 자동 판단: blendName 있거나 컴포넌트 2개 이상
    var isBlend: Bool {
        blendName != nil || blendComponents.count >= 2
    }

    var displayName: String {
        if let blend = blendName, !blend.isEmpty { return blend }
        let parts = [originCountry, originRegion, variety].compactMap { $0 }
        return parts.isEmpty ? "이름 없음" : parts.joined(separator: " ")
    }
}
