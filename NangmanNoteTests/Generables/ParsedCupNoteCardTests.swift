import Testing
@testable import NangmanNote

struct ParsedCupNoteCardTests {
    @Test func displayNameSingleOrigin() {
        let parsed = ParsedCupNoteCard(
            originCountry: "온두라스",
            originRegion: "로스 아라야네스",
            variety: "게이샤",
            tastingNotes: []
        )
        #expect(parsed.displayName == "온두라스 로스 아라야네스 게이샤")
    }

    @Test func displayNameBlend() {
        let parsed = ParsedCupNoteCard(
            blendName: "BBINGTIGER X DEFAULT VALUE",
            tastingNotes: []
        )
        #expect(parsed.displayName == "BBINGTIGER X DEFAULT VALUE")
    }

    @Test func displayNameBlendBeatsSingleOriginFields() {
        let parsed = ParsedCupNoteCard(
            blendName: "TEST BLEND",
            originCountry: "Ethiopia",
            tastingNotes: []
        )
        #expect(parsed.displayName == "TEST BLEND")
    }

    @Test func displayNameEmpty() {
        let parsed = ParsedCupNoteCard(tastingNotes: [])
        #expect(parsed.displayName == "이름 없음")
    }

    @Test func displayNameEmptyBlendName() {
        let parsed = ParsedCupNoteCard(
            blendName: "",
            originCountry: "Honduras",
            tastingNotes: []
        )
        #expect(parsed.displayName == "Honduras")
    }
}
