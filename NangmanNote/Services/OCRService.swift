import Foundation
import Vision
import CoreGraphics

final class OCRService: OCRServicing {
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
