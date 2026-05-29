import Foundation
import SwiftData

@Model
final class StickerLayer {
    @Attribute(.unique) var id: UUID
    var emoji: String
    var positionX: Double  // 0~1
    var positionY: Double  // 0~1
    var scale: Double      // 1.0 기본

    var card: CoffeeCard?

    init(
        id: UUID = UUID(),
        emoji: String,
        positionX: Double = 0.5,
        positionY: Double = 0.5,
        scale: Double = 1.0
    ) {
        self.id = id
        self.emoji = emoji
        self.positionX = positionX
        self.positionY = positionY
        self.scale = scale
    }
}

/// 영상 시연 기본 팔레트 12종 (기획서)
enum StickerPreset {
    static let palette: [String] = [
        "☕", "🌧", "✨", "💜",
        "🎵", "📖", "🌙", "🍃",
        "🥐", "📷", "🌸", "🎨"
    ]
}
