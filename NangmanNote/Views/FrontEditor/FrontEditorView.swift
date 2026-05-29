import SwiftUI

struct FrontEditorView: View {
    @Bindable var card: CoffeeCard
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 20) {
                preview
                    .padding(.horizontal)

                presetPicker

                Spacer()
            }
            .padding(.top, 8)
            .navigationTitle("앞면 꾸미기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private var preview: some View {
        ZStack {
            card.frontBackground.background()
                .clipShape(RoundedRectangle(cornerRadius: 16))

            VStack(spacing: 10) {
                Spacer()
                Image(systemName: "heart.text.square")
                    .font(.system(size: 44))
                    .foregroundStyle(card.frontBackground.preferredTextColor)
                Text(card.displayName)
                    .font(.title3.bold())
                    .foregroundStyle(card.frontBackground.preferredTextColor)
                if let memo = card.userMemo, !memo.isEmpty {
                    Text(memo)
                        .font(.subheadline)
                        .foregroundStyle(card.frontBackground.preferredTextColor.opacity(0.85))
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                }
                Spacer()
            }
            .padding()
        }
        .aspectRatio(0.72, contentMode: .fit)
    }

    private var presetPicker: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("배경")
                .font(.subheadline.bold())
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 12) {
                    ForEach(FrontBackgroundPreset.allCases) { preset in
                        presetSwatch(preset)
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
        }
    }

    private func presetSwatch(_ preset: FrontBackgroundPreset) -> some View {
        let isSelected = card.frontBackground == preset
        return VStack(spacing: 6) {
            preset.background()
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .frame(width: 64, height: 80)
                .overlay {
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 3)
                }
                .overlay(alignment: .topTrailing) {
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.white, Color.accentColor)
                            .padding(4)
                    }
                }

            Text(preset.label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                card.frontBackground = preset
            }
        }
    }
}
