import Foundation
import UIKit

/// Documents/cards/ 안에 카드 사진을 저장/로드.
/// SwiftData는 path(string)만 보관 — 이미지 데이터는 파일시스템.
enum ImageFileStore {
    private static var documentsURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    }

    static var cardsDirectory: URL {
        let url = documentsURL.appendingPathComponent("cards", isDirectory: true)
        try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        return url
    }

    @discardableResult
    static func saveFront(_ image: UIImage, for cardID: UUID, compressionQuality: CGFloat = 0.8) -> String? {
        let filename = "\(cardID.uuidString)-front.jpg"
        let url = cardsDirectory.appendingPathComponent(filename)
        guard let data = image.jpegData(compressionQuality: compressionQuality) else { return nil }
        do {
            try data.write(to: url, options: [.atomic])
            return filename
        } catch {
            return nil
        }
    }

    static func loadFront(filename: String) -> UIImage? {
        let url = cardsDirectory.appendingPathComponent(filename)
        guard let data = try? Data(contentsOf: url) else { return nil }
        return UIImage(data: data)
    }

    static func deleteFront(filename: String) {
        let url = cardsDirectory.appendingPathComponent(filename)
        try? FileManager.default.removeItem(at: url)
    }
}
