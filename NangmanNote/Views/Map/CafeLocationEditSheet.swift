import SwiftUI
import CoreLocation

struct CafeLocationEditSheet: View {
    @Bindable var cafe: Cafe
    @Environment(\.dismiss) private var dismiss

    @State private var query: String
    @State private var candidates: [CafeCandidate] = []
    @State private var isSearching = false
    @State private var errorMessage: String?

    private let lookup = CafeLookupService()

    init(cafe: Cafe) {
        self.cafe = cafe
        self._query = State(initialValue: cafe.name)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("카페명 검색") {
                    TextField("카페명", text: $query)
                        .autocorrectionDisabled()

                    Button {
                        Task { await runSearch() }
                    } label: {
                        if isSearching {
                            HStack { ProgressView(); Text("검색 중…") }
                        } else {
                            Label("MapKit으로 검색", systemImage: "magnifyingglass")
                        }
                    }
                    .disabled(isSearching || query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                if let errorMessage {
                    Section { Text(errorMessage).foregroundStyle(.red).font(.caption) }
                }

                if !candidates.isEmpty {
                    Section("후보") {
                        ForEach(candidates) { candidate in
                            Button {
                                apply(candidate)
                            } label: {
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(candidate.name)
                                        .font(.subheadline.weight(.medium))
                                        .foregroundStyle(.primary)
                                    if let address = candidate.address {
                                        Text(address)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                    }
                                    if let distance = candidate.distance {
                                        Text("\(Int(distance))m")
                                            .font(.caption2.monospacedDigit())
                                            .foregroundStyle(.tertiary)
                                    }
                                }
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }

                if cafe.coordinate != nil {
                    Section {
                        Button("위치 제거", role: .destructive) {
                            cafe.latitude = nil
                            cafe.longitude = nil
                            cafe.address = nil
                            dismiss()
                        }
                    } footer: {
                        Text("위치를 제거하면 지도에는 표시되지 않고 컬렉션에만 남습니다.")
                    }
                }
            }
            .navigationTitle("위치 편집")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { dismiss() }
                }
            }
        }
    }

    private func runSearch() async {
        isSearching = true
        errorMessage = nil
        defer { isSearching = false }

        do {
            let results = try await lookup.search(name: query, near: cafe.coordinate)
            candidates = results
            if results.isEmpty {
                errorMessage = "결과가 없습니다. 다른 검색어를 시도해보세요."
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    private func apply(_ candidate: CafeCandidate) {
        cafe.name = candidate.name
        cafe.latitude = candidate.coordinate.latitude
        cafe.longitude = candidate.coordinate.longitude
        cafe.address = candidate.address
        dismiss()
    }
}
