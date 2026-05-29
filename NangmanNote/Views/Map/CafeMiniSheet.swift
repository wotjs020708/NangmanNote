import SwiftUI

struct CafeMiniSheet: View {
    let summary: MapTabView.CafeSummary
    @Environment(\.dismiss) private var dismiss
    @State private var editingLocation = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    headerRow
                    Divider()
                    cardsGrid
                }
                .padding()
            }
            .navigationTitle(summary.cafe.name)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        editingLocation = true
                    } label: {
                        Image(systemName: "pencil.circle")
                    }
                    .accessibilityLabel("위치 편집")
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") { dismiss() }
                }
            }
            .navigationDestination(for: CoffeeCard.self) { card in
                CardDetailView(card: card)
            }
            .sheet(isPresented: $editingLocation) {
                CafeLocationEditSheet(cafe: summary.cafe)
            }
        }
        .presentationDetents([.medium, .large])
        .presentationDragIndicator(.visible)
    }

    private var headerRow: some View {
        HStack(alignment: .top, spacing: 12) {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 6) {
                    Image(systemName: "mappin.circle.fill")
                        .foregroundStyle(.tint)
                    Text("\(summary.cards.count)잔 방문")
                        .font(.subheadline.weight(.medium))
                }

                if summary.averageRating > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow)
                            .font(.caption)
                        Text(String(format: "평균 %.1f", summary.averageRating))
                            .font(.caption.monospacedDigit())
                            .foregroundStyle(.secondary)
                    }
                }
            }

            Spacer()

            if let address = summary.cafe.address, !address.isEmpty {
                Text(address)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.trailing)
                    .frame(maxWidth: 160)
            }
        }
    }

    private var cardsGrid: some View {
        LazyVGrid(
            columns: [GridItem(.adaptive(minimum: 140), spacing: 10)],
            spacing: 10
        ) {
            ForEach(summary.cards) { card in
                NavigationLink(value: card) {
                    CardCellView(card: card)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
