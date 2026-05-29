import SwiftUI
import MapKit
import CoreLocation
import SwiftData

struct MapTabView: View {
    @Environment(CardStore.self) private var store
    @State private var cameraPosition: MapCameraPosition = .automatic
    @State private var selectedCafeID: PersistentIdentifier?

    var body: some View {
        NavigationStack {
            mapContent
                .navigationTitle("기억의 지도")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        Menu {
                            Button {
                                fitAll()
                            } label: {
                                Label("전체 보기", systemImage: "rectangle.dashed")
                            }
                            Button {
                                cameraPosition = .userLocation(fallback: .automatic)
                            } label: {
                                Label("내 위치", systemImage: "location")
                            }
                        } label: {
                            Image(systemName: "scope")
                        }
                    }
                }
                .navigationDestination(for: CoffeeCard.self) { card in
                    CardDetailView(card: card)
                }
        }
        .onAppear { fitAll() }
        .onChange(of: cafeSummaries.count) { _, _ in fitAll() }
    }

    @ViewBuilder
    private var mapContent: some View {
        if cafeSummaries.isEmpty {
            ContentUnavailableView(
                "지도에 표시할 카페가 없어요",
                systemImage: "map",
                description: Text("카드에 카페 좌표를 추가하면 핀이 표시됩니다.")
            )
        } else {
            Map(position: $cameraPosition, selection: $selectedCafeID) {
                ForEach(cafeSummaries) { summary in
                    Annotation(summary.cafe.name, coordinate: summary.coordinate) {
                        CafePinView(summary: summary)
                    }
                    .tag(summary.id)
                }
            }
            .mapStyle(.standard(elevation: .realistic))
        }
    }

    // MARK: - 데이터 가공

    struct CafeSummary: Identifiable {
        let cafe: Cafe
        let cards: [CoffeeCard]
        let averageRating: Double
        let coordinate: CLLocationCoordinate2D

        var id: PersistentIdentifier { cafe.persistentModelID }
    }

    private var cafeSummaries: [CafeSummary] {
        let withCafe = store.cards.compactMap { card -> (Cafe, CoffeeCard)? in
            guard let cafe = card.cafe, cafe.coordinate != nil else { return nil }
            return (cafe, card)
        }
        let groups = Dictionary(grouping: withCafe, by: { $0.0.persistentModelID })

        return groups.compactMap { _, entries -> CafeSummary? in
            guard let firstCafe = entries.first?.0, let coord = firstCafe.coordinate else { return nil }
            let cards = entries.map { $0.1 }
            let ratings = cards.compactMap { $0.userRating.map(Double.init) }
            let avg = ratings.isEmpty ? 0 : ratings.reduce(0, +) / Double(ratings.count)
            return CafeSummary(cafe: firstCafe, cards: cards, averageRating: avg, coordinate: coord)
        }
        .sorted { $0.cafe.name.localizedCompare($1.cafe.name) == .orderedAscending }
    }

    // MARK: - 카메라

    private func fitAll() {
        let coords = cafeSummaries.map { $0.coordinate }
        guard !coords.isEmpty else { return }

        if coords.count == 1 {
            cameraPosition = .region(MKCoordinateRegion(
                center: coords[0],
                latitudinalMeters: 5_000,
                longitudinalMeters: 5_000
            ))
            return
        }

        let minLat = coords.map(\.latitude).min() ?? 0
        let maxLat = coords.map(\.latitude).max() ?? 0
        let minLon = coords.map(\.longitude).min() ?? 0
        let maxLon = coords.map(\.longitude).max() ?? 0
        let center = CLLocationCoordinate2D(
            latitude: (minLat + maxLat) / 2,
            longitude: (minLon + maxLon) / 2
        )
        let span = MKCoordinateSpan(
            latitudeDelta: max(0.02, (maxLat - minLat) * 1.5),
            longitudeDelta: max(0.02, (maxLon - minLon) * 1.5)
        )
        cameraPosition = .region(MKCoordinateRegion(center: center, span: span))
    }
}

private struct CafePinView: View {
    let summary: MapTabView.CafeSummary

    private var pinColor: Color {
        if summary.averageRating >= 4.5 { return .pink }
        if summary.averageRating >= 4.0 { return .accentColor }
        if summary.averageRating > 0 { return .orange }
        return .gray
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Circle()
                    .fill(pinColor)
                    .frame(width: 40, height: 40)
                    .shadow(color: .black.opacity(0.2), radius: 3, y: 2)
                Text("☕")
                    .font(.title3)
            }
            .overlay(alignment: .topTrailing) {
                if summary.cards.count > 1 {
                    Text("\(summary.cards.count)")
                        .font(.caption2.bold().monospacedDigit())
                        .padding(.horizontal, 5)
                        .padding(.vertical, 2)
                        .background(Color.white)
                        .foregroundStyle(pinColor)
                        .clipShape(Capsule())
                        .overlay(Capsule().stroke(pinColor, lineWidth: 1.5))
                        .offset(x: 4, y: -2)
                }
            }

            Image(systemName: "triangle.fill")
                .rotationEffect(.degrees(180))
                .font(.caption2)
                .foregroundStyle(pinColor)
                .offset(y: -3)
        }
    }
}
