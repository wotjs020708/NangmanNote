import SwiftUI

/// 앞면 — 사용자 추억 면. preset 배경 + 텍스트 레이어 + (이모지 #43).
struct FrontCardView: View {
    let card: CoffeeCard

    var body: some View {
        GeometryReader { geo in
            ZStack {
                if let path = card.frontPhotoPath, let uiImage = ImageFileStore.loadFront(filename: path) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: geo.size.width, height: geo.size.height)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                } else {
                    card.frontBackground.background()
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                }

                if card.textLayers.isEmpty && card.stickerLayers.isEmpty {
                    placeholderContent
                }

                ForEach(card.textLayers) { layer in
                    Text(layer.content)
                        .font(layer.fontStyle.font)
                        .foregroundStyle(layer.color)
                        .position(
                            x: layer.positionX * geo.size.width,
                            y: layer.positionY * geo.size.height
                        )
                }

                ForEach(card.stickerLayers) { sticker in
                    Text(sticker.emoji)
                        .font(.system(size: 36))
                        .position(
                            x: sticker.positionX * geo.size.width,
                            y: sticker.positionY * geo.size.height
                        )
                }
            }
        }
    }

    private var placeholderContent: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "heart.text.square")
                .font(.system(size: 56))
                .foregroundStyle(card.frontBackground.preferredTextColor)
            Text(card.displayName)
                .font(.title3.bold())
                .foregroundStyle(card.frontBackground.preferredTextColor)
                .multilineTextAlignment(.center)
            Spacer()
            Text("탭하여 뒤집기")
                .font(.caption2)
                .foregroundStyle(card.frontBackground.preferredTextColor.opacity(0.6))
                .padding(.bottom, 12)
        }
        .padding()
    }
}
