import Foundation
import SwiftData
import SwiftUI

enum TextFontStyle: String, CaseIterable, Codable, Sendable {
    case body, serif, mono

    var label: String {
        switch self {
        case .body: "기본"
        case .serif: "세리프"
        case .mono: "고정폭"
        }
    }

    var font: Font {
        switch self {
        case .body: .system(.title3, design: .default, weight: .medium)
        case .serif: .system(.title3, design: .serif, weight: .medium)
        case .mono: .system(.title3, design: .monospaced, weight: .medium)
        }
    }
}

struct TextColorPreset: Identifiable, Sendable {
    let id: String
    let label: String
    let color: Color

    static let presets: [TextColorPreset] = [
        .init(id: "#000000", label: "블랙", color: .black),
        .init(id: "#FFFFFF", label: "화이트", color: .white),
        .init(id: "#8B6F47", label: "브라운", color: Color(red: 0.55, green: 0.43, blue: 0.28)),
        .init(id: "#D67A8E", label: "로즈", color: Color(red: 0.84, green: 0.48, blue: 0.56)),
        .init(id: "#2C3E50", label: "네이비", color: Color(red: 0.17, green: 0.24, blue: 0.31))
    ]

    static func color(for hex: String) -> Color {
        presets.first { $0.id == hex }?.color ?? .primary
    }
}

@Model
final class TextLayer {
    @Attribute(.unique) var id: UUID
    var content: String
    var positionX: Double  // 0~1 비율 (좌→우)
    var positionY: Double  // 0~1 비율 (위→아래)
    var fontStyleRaw: String
    var hexColor: String

    var card: CoffeeCard?

    init(
        id: UUID = UUID(),
        content: String,
        positionX: Double = 0.5,
        positionY: Double = 0.5,
        fontStyle: TextFontStyle = .body,
        hexColor: String = "#000000"
    ) {
        self.id = id
        self.content = content
        self.positionX = positionX
        self.positionY = positionY
        self.fontStyleRaw = fontStyle.rawValue
        self.hexColor = hexColor
    }

    var fontStyle: TextFontStyle {
        get { TextFontStyle(rawValue: fontStyleRaw) ?? .body }
        set { fontStyleRaw = newValue.rawValue }
    }

    var color: Color {
        TextColorPreset.color(for: hexColor)
    }
}
