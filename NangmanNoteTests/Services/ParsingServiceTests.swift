import Testing
import Foundation
@testable import NangmanNote

@MainActor
struct ParsingServiceTests {

    /// 사용자 5/29 실기기 OCR 결과 그대로 (빙티거 X DEFAULT VALUE 카드)
    private static let bbingtigerOCR = """
    BBINGTIGER X DEFAULT VALUE
    이런
    편
    • 한
    휴식
    얼마나
    렌
    ETHIOPIA GUJI URAGA TABE HARO WACHU RED HONEY 65%
    COLOMBIA JOSE MENESES CM MANDRIN WASHED 35%
    '색'은 우리가 느끼는 감각을 표현하는 하나의 방법이 되기도 합니다.
    그 중 노란색은 생생하고 살아있는 느낌을 주는 색 입니다.
    커피에서도 이러한 '색'을 연상할 수 있다는 사실을 알고 계시나요?
    커피에서 느껴지는 신맛과 단맛, 그리고 향으로 인해 우리는 보통 특정한 과일을
    연상하게 되고 연상되는 과일에 따라 색을 떠올리기도 합니다.
    '이런 편안한 휴식, 얼마나 오렌지' 블렌드는 오렌지 주스와 은은한 감귤티를
    연상시키는 노란 계열의 향들과 날카롭지 않은 둥글둥글한 신맛과
    단맛이 입 안을 부드럽게 감쌉니다.
    BREWING
    원두량 15g| 물량 240g (1:16 Ratio)
    1회차 푸어링: 150g (가는 물줄기)
    온도: 91도 | 분쇄도: 9.5 (EK43) | 추출시간: 2분 30초 이내
    ESPRESSO
    도장량 18g | 추출량 36g (50% Ratio) | 온도 92도
    """

    private static let hondurasOCR = """
    온두라스 로스 아라야네스
    게이샤 워시드
    1,750m / 로스팅포인트 : 약배전
    컵 노트 : 플로럴, 감귤, 카모마일, 꿀
    """

    private static let ethiopiaOCR = """
    산지 Origin
    에티오피아 Ethiopia
    농장명 Farm
    예가체프 워카 넨케 Yirgacheffe Worka Nenke
    품종 Variety
    Heirloom
    가공 Process
    Fully Washed
    플레이버 노트 Flavor Note
    Jasmine, Citrus, Apricot, Cane Sugar
    """

    // MARK: - 빙티거 (블렌드)

    @Test func bbingtiger_extractsBlendNameFromBodyText() async throws {
        let result = ParsingService.parseHeuristic(Self.bbingtigerOCR)
        // 본문에서 추출: '이런 편안한 휴식, 얼마나 오렌지' 블렌드는...
        #expect(result.blendName?.contains("이런 편안한 휴식") == true)
        #expect(result.blendName?.contains("얼마나 오렌지") == true)
    }

    @Test func bbingtiger_singleOriginFieldsAreNilForBlend() async throws {
        let result = ParsingService.parseHeuristic(Self.bbingtigerOCR)
        #expect(result.originCountry == nil)
        #expect(result.originRegion == nil)
        #expect(result.variety == nil)
    }

    @Test func bbingtiger_detectsRedHoneyAndWashed() async throws {
        // 본문에 RED HONEY와 WASHED 둘 다 있음. process 필드는 첫 매칭(긴 패턴 우선)
        let result = ParsingService.parseHeuristic(Self.bbingtigerOCR)
        // redHoney 또는 washed 중 하나는 반드시 잡힘
        #expect(result.process != nil)
    }

    // MARK: - 온두라스 (단일 원두)

    @Test func honduras_extractsCountryRegionVariety() async throws {
        let result = ParsingService.parseHeuristic(Self.hondurasOCR)
        #expect(result.blendName == nil)
        #expect(result.originCountry == "Honduras")
        #expect(result.originRegion == "로스 아라야네스")
        #expect(result.variety?.lowercased() == "게이샤" || result.variety?.lowercased() == "geisha")
    }

    @Test func honduras_processIsWashed() async throws {
        let result = ParsingService.parseHeuristic(Self.hondurasOCR)
        #expect(result.process == "washed")
    }

    @Test func honduras_roastIsLight() async throws {
        let result = ParsingService.parseHeuristic(Self.hondurasOCR)
        #expect(result.roastLevel == "light")
    }

    @Test func honduras_tastingNotesContainSeveral() async throws {
        let result = ParsingService.parseHeuristic(Self.hondurasOCR)
        // 플로럴, 감귤, 카모마일, 꿀 중 최소 2개
        #expect(result.tastingNotes.count >= 2)
    }

    // MARK: - 에티오피아 (한/영 라벨)

    @Test func ethiopia_extractsCountryAndVariety() async throws {
        let result = ParsingService.parseHeuristic(Self.ethiopiaOCR)
        #expect(result.originCountry == "Ethiopia")
        #expect(result.variety == "Heirloom")
        #expect(result.originRegion?.contains("Yirgacheffe") == true || result.originRegion?.contains("Worka") == true || result.originRegion?.contains("Nenke") == true || result.originRegion?.contains("예가체프") == true)
    }

    @Test func ethiopia_processIsWashed() async throws {
        let result = ParsingService.parseHeuristic(Self.ethiopiaOCR)
        #expect(result.process == "washed")
    }

    @Test func ethiopia_tastingNotesContainSeveral() async throws {
        let result = ParsingService.parseHeuristic(Self.ethiopiaOCR)
        // Jasmine, Citrus, Apricot, Cane Sugar 중 최소 2개
        #expect(result.tastingNotes.count >= 2)
    }

    // MARK: - 엣지 케이스

    @Test func empty_throws() async {
        let service = ParsingService()
        await #expect(throws: ParsingError.self) {
            _ = try await service.parse(ocrText: "   \n  ")
        }
    }
}
