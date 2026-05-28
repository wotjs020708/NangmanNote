import Foundation

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

    init(
        blendName: String? = nil,
        originCountry: String? = nil,
        originRegion: String? = nil,
        variety: String? = nil,
        process: String? = nil,
        roastLevel: String? = nil,
        tastingNotes: [String] = [],
        cafeName: String? = nil
    ) {
        self.blendName = blendName
        self.originCountry = originCountry
        self.originRegion = originRegion
        self.variety = variety
        self.process = process
        self.roastLevel = roastLevel
        self.tastingNotes = tastingNotes
        self.cafeName = cafeName
    }
}

extension ParsedCupNoteCard {
    var displayName: String {
        if let blend = blendName, !blend.isEmpty { return blend }
        let parts = [originCountry, originRegion, variety].compactMap { $0 }
        return parts.isEmpty ? "이름 없음" : parts.joined(separator: " ")
    }
}
