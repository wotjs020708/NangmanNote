import SwiftUI
import SwiftData

struct CardDetailView: View {
    @Bindable var card: CoffeeCard
    @State private var showingFront = false  // 첫 진입: 뒷면(AI 정보) 표시
    @State private var showingFrontEditor = false

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                FlipContainer(showingFront: $showingFront) {
                    FrontCardView(card: card)
                } back: {
                    BackCardView(card: card)
                }
                .aspectRatio(0.72, contentMode: .fit)
                .padding(.horizontal)
                .padding(.top, 8)

                VStack(alignment: .leading, spacing: 16) {
                    ratingRow
                    memoRow
                    metaRow
                }
                .padding(.horizontal)
                .padding(.bottom, 24)
            }
        }
        .navigationTitle(card.displayName)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    showingFrontEditor = true
                } label: {
                    Label("앞면 꾸미기", systemImage: "paintbrush.pointed")
                }
            }
        }
        .sheet(isPresented: $showingFrontEditor) {
            FrontEditorView(card: card)
        }
    }

    private var ratingRow: some View {
        HStack {
            Text("별점")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
            StarRatingView(rating: Binding(
                get: { card.userRating ?? 0 },
                set: { card.userRating = $0 > 0 ? $0 : nil }
            ))
        }
    }

    private var memoRow: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text("메모")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            TextField(
                "이 커피의 기억…",
                text: Binding(
                    get: { card.userMemo ?? "" },
                    set: { card.userMemo = $0.isEmpty ? nil : $0 }
                ),
                axis: .vertical
            )
            .lineLimit(2...6)
            .textFieldStyle(.roundedBorder)
        }
    }

    private var metaRow: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 6) {
                Image(systemName: "calendar")
                Text(card.visitedOn.formatted(date: .abbreviated, time: .omitted))
                Spacer()
                if let confidence = card.parsingConfidence {
                    Text("AI 신뢰도 \(Int(confidence * 100))%")
                        .foregroundStyle(confidence < 0.5 ? .orange : .secondary)
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }
}

struct StarRatingView: View {
    @Binding var rating: Int

    var body: some View {
        HStack(spacing: 6) {
            ForEach(1...5, id: \.self) { i in
                Image(systemName: i <= rating ? "star.fill" : "star")
                    .font(.title3)
                    .foregroundStyle(.yellow)
                    .onTapGesture {
                        rating = (i == rating) ? 0 : i
                    }
                    .accessibilityLabel("\(i) 점")
            }
        }
    }
}
