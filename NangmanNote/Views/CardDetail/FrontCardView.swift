import SwiftUI

/// 앞면 — 사용자 추억 면. M4 Front Editor에서 본격 구현.
struct FrontCardView: View {
    let card: CoffeeCard

    var body: some View {
        VStack(spacing: 16) {
            Spacer()

            Image(systemName: "heart.text.square")
                .font(.system(size: 56))
                .foregroundStyle(.tint)

            VStack(spacing: 8) {
                Text(card.displayName)
                    .font(.title3.bold())
                    .multilineTextAlignment(.center)

                if let memo = card.userMemo, !memo.isEmpty {
                    Text(memo)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                } else {
                    Text("앞면 꾸미기는 M4에서 추가됩니다.")
                        .font(.caption)
                        .foregroundStyle(.tertiary)
                }
            }

            Spacer()

            Text("탭하여 뒤집기")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .padding(.bottom, 12)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            LinearGradient(
                colors: [.accentColor.opacity(0.18), .purple.opacity(0.18)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}
