import SwiftUI
import UIKit

@MainActor
enum CardImageRenderer {
    /// 카드의 앞+뒷면을 위아래 한 장 이미지로 렌더링.
    /// 영상 시연 / 카드 공유용.
    static func renderFrontAndBack(
        card: CoffeeCard,
        size: CGSize = CGSize(width: 600, height: 1200),
        scale: CGFloat = 2.0
    ) -> UIImage? {
        let cardHeight = (size.height - 100) / 2  // 패딩·간격 고려

        let content = VStack(spacing: 16) {
            FrontCardView(card: card)
                .frame(width: size.width - 48, height: cardHeight)
            BackCardView(card: card)
                .frame(width: size.width - 48, height: cardHeight)
        }
        .padding(24)
        .frame(width: size.width, height: size.height)
        .background(Color(.systemBackground))

        let renderer = ImageRenderer(content: content)
        renderer.scale = scale
        renderer.proposedSize = ProposedViewSize(size)
        return renderer.uiImage
    }
}
