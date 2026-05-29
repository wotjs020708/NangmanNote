import SwiftUI

struct CollectionView: View {
    @Environment(CardStore.self) private var store
    @State private var showingModeSelect = false
    @State private var showingSearch = false
    @State private var sortOrder: SortOption = .latest

    enum SortOption: String, CaseIterable, Identifiable {
        case latest, rating, cafe

        var id: String { rawValue }
        var label: String {
            switch self {
            case .latest: "최신순"
            case .rating: "별점순"
            case .cafe: "카페순"
            }
        }
        var iconName: String {
            switch self {
            case .latest: "clock"
            case .rating: "star.fill"
            case .cafe: "mappin.circle"
            }
        }
    }

    private var sortedCards: [CoffeeCard] {
        switch sortOrder {
        case .latest:
            return store.cards
        case .rating:
            return store.cards.sorted { ($0.userRating ?? 0) > ($1.userRating ?? 0) }
        case .cafe:
            return store.cards.sorted { lhs, rhs in
                let lname = lhs.cafe?.name ?? "\u{FFFF}"
                let rname = rhs.cafe?.name ?? "\u{FFFF}"
                return lname.localizedCompare(rname) == .orderedAscending
            }
        }
    }

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
                            ForEach(sortedCards) { card in
                                NavigationLink(value: card) {
                                    CardCellView(card: card)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle("낭만 노트")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingSearch = true
                    } label: {
                        Image(systemName: "magnifyingglass")
                            .font(.title3)
                    }
                    .accessibilityLabel("검색")
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Menu {
                        ForEach(SortOption.allCases) { option in
                            Button {
                                sortOrder = option
                            } label: {
                                Label(option.label, systemImage: option.iconName)
                            }
                        }
                    } label: {
                        Image(systemName: "arrow.up.arrow.down")
                            .font(.title3)
                    }
                    .accessibilityLabel("정렬")
                }

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
            .navigationDestination(for: CoffeeCard.self) { card in
                CardDetailView(card: card)
            }
            .sheet(isPresented: $showingModeSelect) {
                ModeSelectView()
            }
            .sheet(isPresented: $showingSearch) {
                NavigationStack {
                    SearchView(viewModel: SearchViewModel(store: store))
                        .toolbar {
                            ToolbarItem(placement: .topBarLeading) {
                                Button("닫기") { showingSearch = false }
                            }
                        }
                }
            }
        }
    }
}
