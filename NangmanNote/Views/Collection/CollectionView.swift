import SwiftUI

struct CollectionView: View {
    @Environment(CardStore.self) private var store
    @State private var showingModeSelect = false

    var body: some View {
        NavigationStack {
            Group {
                if store.cards.isEmpty {
                    ContentUnavailableView(
                        "아직 카드가 없습니다",
                        systemImage: "square.grid.2x2",
                        description: Text("우상단 + 버튼으로 첫 카드를 추가하세요")
                    )
                } else {
                    ScrollView {
                        LazyVGrid(
                            columns: [GridItem(.adaptive(minimum: 160), spacing: 12)],
                            spacing: 12
                        ) {
                            ForEach(store.cards) { card in
                                CardCellView(card: card)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("낭만 노트")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingModeSelect = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.title3)
                    }
                    .accessibilityLabel("카드 추가")
                }
            }
            .sheet(isPresented: $showingModeSelect) {
                ModeSelectView()
            }
        }
    }
}
