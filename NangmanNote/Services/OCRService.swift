import Foundation
import Vision
import CoreGraphics

final class OCRService: OCRServicing {
    /// Vision의 후보 단어 힌트. 카드에서 자주 등장하는 산지·품종·가공·라벨 용어.
    /// 깨진 큰 글씨를 보정하기보다는 본문 단어 정확도를 끌어올리는 목적.
    static let customWords: [String] = [
        // 산지 (국가)
        "Ethiopia", "Honduras", "Colombia", "Kenya", "Brazil", "Guatemala",
        "Costa Rica", "Panama", "Rwanda", "Burundi", "El Salvador", "Nicaragua",
        "Bolivia", "Peru", "Mexico", "Tanzania", "Indonesia", "Yemen",
        "에티오피아", "온두라스", "콜롬비아", "케냐", "브라질", "과테말라",
        "코스타리카", "파나마", "르완다", "엘살바도르", "니카라과", "예멘",

        // 산지 (지역/농장 — 자주 등장)
        "Yirgacheffe", "Guji", "Sidamo", "Sidama", "Worka", "Nenke",
        "Huehuetenango", "Antigua", "Tarrazu", "Boquete", "Geisha Estate",
        "예가체프", "구지", "시다모", "와카",

        // 품종
        "Geisha", "Heirloom", "Bourbon", "Typica", "Caturra", "Pacamara",
        "SL28", "SL34", "Ruiru", "Catimor", "Mundo Novo",
        "게이샤", "버번", "티피카", "카투라",

        // 가공
        "Washed", "Fully Washed", "Natural", "Honey", "Red Honey", "Yellow Honey",
        "Anaerobic", "Carbonic Maceration", "Wet Hulled", "Black Honey",
        "워시드", "내추럴", "허니", "레드 허니", "옐로우 허니", "무산소발효",

        // 노트 (자주 등장)
        "Jasmine", "Blueberry", "Citrus", "Apricot", "Cane Sugar", "Caramel",
        "Chocolate", "Dark Chocolate", "Strawberry", "Peach", "Floral", "Bergamot",
        "자스민", "블루베리", "감귤", "오렌지", "캐러멜", "초콜릿", "딸기", "복숭아",
        "플로럴", "베르가못", "카모마일",

        // 라벨/카드 용어
        "산지", "농장", "품종", "가공", "로스팅", "노트", "테이스팅",
        "Origin", "Farm", "Variety", "Process", "Roast", "Tasting", "Flavor",
        "블렌드", "Blend", "원두", "Bean", "에스프레소", "Espresso",
        "BREWING", "Ratio", "추출시간", "분쇄도",

        // 로스팅
        "Light", "Medium", "Dark", "Medium Light", "Medium Dark",
        "약배전", "중배전", "강배전", "중강배전"
    ]

    init() {}

    func recognize(_ image: CGImage) async throws -> [OCRBlock] {
        try await withCheckedThrowingContinuation { (cont: CheckedContinuation<[OCRBlock], Error>) in
            let request = VNRecognizeTextRequest { req, err in
                if let err {
                    cont.resume(throwing: err)
                    return
                }
                let observations = (req.results as? [VNRecognizedTextObservation]) ?? []
                let blocks = observations.compactMap { obs -> OCRBlock? in
                    guard let top = obs.topCandidates(1).first else { return nil }
                    return OCRBlock(
                        text: top.string,
                        boundingBox: obs.boundingBox,
                        confidence: top.confidence
                    )
                }
                cont.resume(returning: blocks)
            }
            request.recognitionLevel = .accurate
            request.recognitionLanguages = ["ko-KR", "en-US"]
            request.usesLanguageCorrection = true
            request.automaticallyDetectsLanguage = true
            request.customWords = Self.customWords
            request.minimumTextHeight = 0   // 큰/작은 글씨 모두

            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            do {
                try handler.perform([request])
            } catch {
                cont.resume(throwing: error)
            }
        }
    }
}

struct MockOCRService: OCRServicing {
    let fixedBlocks: [OCRBlock]

    init(fixedBlocks: [OCRBlock] = []) {
        self.fixedBlocks = fixedBlocks
    }

    func recognize(_ image: CGImage) async throws -> [OCRBlock] {
        fixedBlocks
    }
}

extension Array where Element == OCRBlock {
    /// 좌→우, 위→아래로 정렬. Vision boundingBox는 좌하단 원점이라 y가 클수록 위.
    /// 같은 행끼리 그룹화한 뒤 행 내부에서 x 정렬.
    func sortedReadingOrder() -> [OCRBlock] {
        guard !isEmpty else { return [] }

        let byY = sorted { $0.boundingBox.midY > $1.boundingBox.midY }
        let rowTolerance: CGFloat = 0.02

        var rows: [[OCRBlock]] = []
        for block in byY {
            if let lastIdx = rows.indices.last,
               let anchor = rows[lastIdx].first,
               abs(anchor.boundingBox.midY - block.boundingBox.midY) < rowTolerance {
                rows[lastIdx].append(block)
            } else {
                rows.append([block])
            }
        }

        return rows.flatMap { row in
            row.sorted { $0.boundingBox.midX < $1.boundingBox.midX }
        }
    }

    func joinedText(separator: String = "\n") -> String {
        sortedReadingOrder().map(\.text).joined(separator: separator)
    }
}
