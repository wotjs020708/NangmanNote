import SwiftUI

/// 앞면 배경 프리셋 — 단색 6 + 그라데이션 4 = 10종.
/// 사용자는 hex를 직접 입력하지 않고 프리셋만 선택.
enum FrontBackgroundPreset: String, CaseIterable, Codable, Identifiable, Sendable {
    case white, cream, sand, sage, lavender, dusk
    case oceanGradient, sunsetGradient, forestGradient, peachGradient

    var id: String { rawValue }

    var label: String {
        switch self {
        case .white: "화이트"
        case .cream: "크림"
        case .sand: "샌드"
        case .sage: "세이지"
        case .lavender: "라벤더"
        case .dusk: "더스크"
        case .oceanGradient: "오션"
        case .sunsetGradient: "선셋"
        case .forestGradient: "포레스트"
        case .peachGradient: "피치"
        }
    }

    var isGradient: Bool {
        switch self {
        case .oceanGradient, .sunsetGradient, .forestGradient, .peachGradient: true
        default: false
        }
    }

    /// 일관된 시각용 ShapeStyle. View에서 .background()에 그대로 적용 가능.
    @ViewBuilder
    func background() -> some View {
        switch self {
        case .white: Color(red: 1.00, green: 1.00, blue: 1.00)
        case .cream: Color(red: 0.97, green: 0.93, blue: 0.86)
        case .sand: Color(red: 0.91, green: 0.84, blue: 0.71)
        case .sage: Color(red: 0.78, green: 0.85, blue: 0.78)
        case .lavender: Color(red: 0.84, green: 0.81, blue: 0.92)
        case .dusk: Color(red: 0.32, green: 0.30, blue: 0.45)
        case .oceanGradient:
            LinearGradient(
                colors: [Color(red: 0.45, green: 0.72, blue: 0.86), Color(red: 0.27, green: 0.42, blue: 0.66)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .sunsetGradient:
            LinearGradient(
                colors: [Color(red: 0.99, green: 0.74, blue: 0.49), Color(red: 0.93, green: 0.43, blue: 0.51)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .forestGradient:
            LinearGradient(
                colors: [Color(red: 0.55, green: 0.74, blue: 0.55), Color(red: 0.20, green: 0.43, blue: 0.31)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        case .peachGradient:
            LinearGradient(
                colors: [Color(red: 1.00, green: 0.86, blue: 0.79), Color(red: 0.97, green: 0.65, blue: 0.60)],
                startPoint: .topLeading, endPoint: .bottomTrailing
            )
        }
    }

    /// 텍스트 색상 (배경과 대비). 어두운 배경엔 흰색.
    var preferredTextColor: Color {
        switch self {
        case .dusk, .oceanGradient, .forestGradient: .white
        default: .primary
        }
    }
}
