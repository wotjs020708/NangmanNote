import Foundation
import UIKit
import Vision
import CoreImage
import CoreImage.CIFilterBuiltins
import ImageIO

struct DetectedRectangle: Sendable {
    let topLeft: CGPoint
    let topRight: CGPoint
    let bottomLeft: CGPoint
    let bottomRight: CGPoint
}

final class ImagePreprocessor {
    private let ciContext: CIContext

    init(ciContext: CIContext = CIContext()) {
        self.ciContext = ciContext
    }

    /// EXIF 회전 정보를 적용해 up-orientation CGImage 반환.
    /// 이미 .up 이면 원본 CGImage 그대로.
    func normalizeOrientation(_ image: UIImage) -> CGImage? {
        guard let cgImage = image.cgImage else { return nil }
        let cgOrientation = CGImagePropertyOrientation(image.imageOrientation)
        if cgOrientation == .up { return cgImage }
        let ciImage = CIImage(cgImage: cgImage).oriented(cgOrientation)
        return ciContext.createCGImage(ciImage, from: ciImage.extent)
    }

    /// 카드 후보 사각형 1개 검출. 검출 실패 시 nil.
    func detectCardRectangle(_ image: CGImage) async -> DetectedRectangle? {
        await withCheckedContinuation { (cont: CheckedContinuation<DetectedRectangle?, Never>) in
            let request = VNDetectRectanglesRequest { req, _ in
                guard let obs = (req.results as? [VNRectangleObservation])?.first else {
                    cont.resume(returning: nil)
                    return
                }
                cont.resume(returning: DetectedRectangle(
                    topLeft: obs.topLeft,
                    topRight: obs.topRight,
                    bottomLeft: obs.bottomLeft,
                    bottomRight: obs.bottomRight
                ))
            }
            request.maximumObservations = 1
            request.minimumConfidence = 0.6
            request.minimumAspectRatio = 0.3
            request.maximumAspectRatio = 1.0
            request.minimumSize = 0.3

            let handler = VNImageRequestHandler(cgImage: image, options: [:])
            try? handler.perform([request])
        }
    }

    /// CIPerspectiveCorrection 으로 원근 보정. 실패 시 nil.
    func perspectiveCorrect(_ image: CGImage, rectangle: DetectedRectangle) -> CGImage? {
        let ciImage = CIImage(cgImage: image)
        let width = CGFloat(image.width)
        let height = CGFloat(image.height)

        func toPixels(_ p: CGPoint) -> CGPoint {
            CGPoint(x: p.x * width, y: p.y * height)
        }

        let filter = CIFilter.perspectiveCorrection()
        filter.inputImage = ciImage
        filter.topLeft = toPixels(rectangle.topLeft)
        filter.topRight = toPixels(rectangle.topRight)
        filter.bottomLeft = toPixels(rectangle.bottomLeft)
        filter.bottomRight = toPixels(rectangle.bottomRight)

        guard let output = filter.outputImage else { return nil }
        return ciContext.createCGImage(output, from: output.extent)
    }

    /// 통합: orientation 정규화 → rectangle 검출 → perspective 보정.
    /// 검출/보정 실패 시 orientation만 정규화한 이미지를 반환 (사용자가 수동 크롭 가능하도록).
    func process(_ uiImage: UIImage) async -> CGImage? {
        guard let normalized = normalizeOrientation(uiImage) else { return uiImage.cgImage }
        if let rect = await detectCardRectangle(normalized),
           let corrected = perspectiveCorrect(normalized, rectangle: rect) {
            return corrected
        }
        return normalized
    }
}

extension CGImagePropertyOrientation {
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up: self = .up
        case .down: self = .down
        case .left: self = .left
        case .right: self = .right
        case .upMirrored: self = .upMirrored
        case .downMirrored: self = .downMirrored
        case .leftMirrored: self = .leftMirrored
        case .rightMirrored: self = .rightMirrored
        @unknown default: self = .up
        }
    }
}
