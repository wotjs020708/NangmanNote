import SwiftUI
import UIKit

/// 뒷면 — 카드의 객관 정보. AI 추출/사용자 편집 결과.
struct BackCardView: View {
    let card: CoffeeCard
    var onTapNote: ((String) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(card.displayName)
                .font(.title3.bold())
                .lineLimit(2)

            if !card.blendComponents.isEmpty {
                blendComponentsSection
            } else {
                singleOriginSection
            }

            if !card.tastingNotes.isEmpty {
                tastingNotesSection
            }

            if let cafe = card.cafe {
                cafeRow(cafe.name)
            }

            Spacer(minLength: 0)

            HStack {
                Spacer()
                Text("탭하여 뒤집기")
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(20)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color(.secondarySystemGroupedBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }

    private var blendComponentsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("블렌드 구성", systemImage: "leaf.fill")
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            ForEach(card.blendComponents) { comp in
                HStack(alignment: .firstTextBaseline) {
                    Text(comp.country)
                        .font(.subheadline.weight(.medium))
                    if let process = comp.process {
                        Text("· \(process)")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    if let ratio = comp.ratio {
                        Text("\(ratio)%")
                            .font(.subheadline.monospacedDigit())
                            .foregroundStyle(.tint)
                    }
                }
            }
        }
    }

    private var singleOriginSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            infoRow("산지", joined(card.originCountry, card.originRegion))
            infoRow("품종", card.variety)
            infoRow("가공", card.process?.rawValue)
            infoRow("로스팅", card.roastLevel?.rawValue)
        }
    }

    private var tastingNotesSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Label("테이스팅 노트", systemImage: "drop.fill")
                .font(.caption.bold())
                .foregroundStyle(.secondary)

            LazyVGrid(columns: [GridItem(.adaptive(minimum: 70), spacing: 6)], alignment: .leading, spacing: 6) {
                ForEach(card.tastingNotes) { note in
                    Text(note.label)
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(Color.accentColor.opacity(0.12))
                        .foregroundStyle(.tint)
                        .clipShape(Capsule())
                        .contentShape(Capsule())
                        .onTapGesture { onTapNote?(note.label) }
                }
            }
        }
    }

    private func cafeRow(_ name: String) -> some View {
        HStack(spacing: 6) {
            Image(systemName: "mappin.and.ellipse")
            Text(name)
        }
        .font(.caption)
        .foregroundStyle(.secondary)
    }

    @ViewBuilder
    private func infoRow(_ label: String, _ value: String?) -> some View {
        if let value, !value.isEmpty {
            HStack(alignment: .firstTextBaseline) {
                Text(label)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .frame(width: 50, alignment: .leading)
                Text(value)
                    .font(.subheadline)
            }
        }
    }

    private func joined(_ a: String?, _ b: String?) -> String? {
        let parts = [a, b].compactMap { $0?.isEmpty == false ? $0 : nil }
        return parts.isEmpty ? nil : parts.joined(separator: " ")
    }
}
