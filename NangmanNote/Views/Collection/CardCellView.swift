import SwiftUI

struct CardCellView: View {
    let card: CoffeeCard

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.gray.opacity(0.15))
                .aspectRatio(1.4, contentMode: .fit)
                .overlay {
                    Image(systemName: "doc.text")
                        .foregroundStyle(.secondary)
                        .font(.largeTitle)
                }

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
}
