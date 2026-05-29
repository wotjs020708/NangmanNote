import SwiftUI

/// 앞면 — 사용자 추억 면. preset 배경 + 카드명 + 메모 미리보기.
struct FrontCardView: View {
    let card: CoffeeCard

    var body: some View {
        ZStack {
            card.frontBackground.background()
                .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(spacing: 16) {
                Spacer()

                Image(systemName: "heart.text.square")
                    .font(.system(size: 56))
                    .foregroundStyle(card.frontBackground.preferredTextColor)

                VStack(spacing: 8) {
                    Text(card.displayName)
                        .font(.title3.bold())
                        .foregroundStyle(card.frontBackground.preferredTextColor)
                        .multilineTextAlignment(.center)

                    if let memo = card.userMemo, !memo.isEmpty {
                        Text(memo)
                            .font(.subheadline)
                            .foregroundStyle(card.frontBackground.preferredTextColor.opacity(0.85))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal)
                    }
                }

                Spacer()

                Text("탭하여 뒤집기")
                    .font(.caption2)
                    .foregroundStyle(card.frontBackground.preferredTextColor.opacity(0.6))
                    .padding(.bottom, 12)
            }
            .padding()
        }
    }
}
