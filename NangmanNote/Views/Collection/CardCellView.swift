import SwiftUI

struct CardCellView: View {
    let card: CoffeeCard
    @State private var showingFront = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            cardPreview

            VStack(alignment: .leading, spacing: 4) {
                Text(card.displayName)
                    .font(.subheadline.weight(.medium))
                    .lineLimit(2)

                if let cafe = card.cafe {
                    Text(cafe.name)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }

                if let rating = card.userRating, rating > 0 {
                    HStack(spacing: 2) {
                        ForEach(0..<rating, id: \.self) { _ in
                            Image(systemName: "star.fill")
                                .font(.caption2)
                                .foregroundStyle(.yellow)
                        }
                    }
                }
            }
            .padding(.horizontal, 4)
        }
    }

    private var cardPreview: some View {
        ZStack {
            backPreview
                .opacity(showingFront ? 0 : 1)
                .rotation3DEffect(.degrees(showingFront ? -180 : 0), axis: (x: 0, y: 1, z: 0))

            frontPreview
                .opacity(showingFront ? 1 : 0)
                .rotation3DEffect(.degrees(showingFront ? 0 : 180), axis: (x: 0, y: 1, z: 0))
        }
        .aspectRatio(1.4, contentMode: .fit)
        .animation(.spring(response: 0.5, dampingFraction: 0.75), value: showingFront)
        .onLongPressGesture(minimumDuration: 0.3, maximumDistance: 10) {
            // 의도적으로 비움 — onPressingChanged에서 토글 처리
        } onPressingChanged: { isPressing in
            showingFront = isPressing
        }
        .accessibilityHint("길게 눌러 앞면 미리보기")
    }

    private var backPreview: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(Color.gray.opacity(0.15))
            .overlay {
                Image(systemName: "doc.text")
                    .foregroundStyle(.secondary)
                    .font(.largeTitle)
            }
    }

    private var frontPreview: some View {
        RoundedRectangle(cornerRadius: 12)
            .fill(
                LinearGradient(
                    colors: [.accentColor.opacity(0.22), .purple.opacity(0.22)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .overlay {
                Image(systemName: "heart.text.square")
                    .foregroundStyle(.tint)
                    .font(.title)
            }
    }
}
