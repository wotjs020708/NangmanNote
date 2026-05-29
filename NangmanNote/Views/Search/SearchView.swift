import SwiftUI

struct SearchView: View {
    @State var viewModel: SearchViewModel

    var body: some View {
        VStack(spacing: 0) {
            searchBar
                .padding(.horizontal)
                .padding(.vertical, 10)

            filterChips

            Divider()

            resultsList
        }
        .navigationTitle("검색")
        .navigationBarTitleDisplayMode(.inline)
        .navigationDestination(for: CoffeeCard.self) { card in
            CardDetailView(card: card)
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.secondary)
            TextField("원두·카페·노트 검색", text: $viewModel.query)
                .textFieldStyle(.plain)
                .autocorrectionDisabled()
            if !viewModel.query.isEmpty {
                Button {
                    viewModel.query = ""
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.tertiary)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(10)
        .background(Color.gray.opacity(0.12))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }

    private var filterChips: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                if viewModel.hasActiveFilters {
                    Button("필터 초기화") { viewModel.resetFilters() }
                        .font(.caption)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.red.opacity(0.12))
                        .foregroundStyle(.red)
                        .clipShape(Capsule())
                }

                ratingChip
                ForEach(viewModel.availableCountries, id: \.self) { country in
                    chip(country, isSelected: viewModel.selectedCountries.contains(country)) {
                        viewModel.toggle(country: country)
                    }
                }
                ForEach(ProcessMethod.allCases, id: \.self) { process in
                    chip(process.rawValue, isSelected: viewModel.selectedProcesses.contains(process)) {
                        viewModel.toggle(process: process)
                    }
                }
                ForEach(viewModel.availableNotes, id: \.self) { note in
                    chip(note, isSelected: viewModel.selectedNotes.contains(note)) {
                        viewModel.toggle(note: note)
                    }
                }
            }
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
    }

    private var ratingChip: some View {
        Menu {
            Button("전체") { viewModel.minimumRating = 0 }
            Button("★ 3 이상") { viewModel.minimumRating = 3 }
            Button("★ 4 이상") { viewModel.minimumRating = 4 }
            Button("★ 5") { viewModel.minimumRating = 5 }
        } label: {
            HStack(spacing: 4) {
                Image(systemName: "star.fill")
                if viewModel.minimumRating > 0 {
                    Text("\(viewModel.minimumRating)+")
                        .font(.caption.monospacedDigit())
                } else {
                    Text("별점")
                }
            }
            .font(.caption)
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(viewModel.minimumRating > 0 ? Color.yellow.opacity(0.18) : Color.gray.opacity(0.12))
            .clipShape(Capsule())
        }
    }

    private func chip(_ label: String, isSelected: Bool, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(label)
                .font(.caption)
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(isSelected ? Color.accentColor.opacity(0.22) : Color.gray.opacity(0.12))
                .foregroundStyle(isSelected ? Color.accentColor : Color.primary)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }

    @ViewBuilder
    private var resultsList: some View {
        let results = viewModel.results
        if results.isEmpty {
            ContentUnavailableView(
                viewModel.query.isEmpty && !viewModel.hasActiveFilters
                    ? "검색어를 입력하세요"
                    : "결과 없음",
                systemImage: "magnifyingglass",
                description: Text(viewModel.query.isEmpty && !viewModel.hasActiveFilters
                    ? "원두·카페·노트로 검색할 수 있습니다."
                    : "다른 검색어나 필터를 시도해보세요.")
            )
        } else {
            ScrollView {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 160), spacing: 12)],
                    spacing: 12
                ) {
                    ForEach(results) { card in
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
}
