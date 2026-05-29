import Foundation

struct ParsedBlendComponent: Sendable, Equatable, Hashable {
    let country: String
    let region: String?
    let variety: String?
    let process: String?
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

// M1.2 (#2) 에서 @Generable + @Guide 매크로로 본격 정의 예정. 현재는 stub.
struct ParsedCupNoteCard: Sendable, Equatable {
    let blendName: String?
    let originCountry: String?
    let originRegion: String?
    let variety: String?
    let process: String?
    let roastLevel: String?
    let tastingNotes: [String]
    let cafeName: String?
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
