import Foundation
import CoreGraphics

protocol OCRServicing: Sendable {
    func recognize(_ image: CGImage) async throws -> [OCRBlock]
}

struct OCRBlock: Sendable {
    let text: String
    let boundingBox: CGRect
    let confidence: Float
}
