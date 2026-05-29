import SwiftUI

struct ModeSelectView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()

                ModeCard(
                    title: "자동 인식",
                    subtitle: "AI가 카드 정보를 자동으로 채웁니다",
                    iconName: "wand.and.stars",
                    color: .accentColor
                ) {
                    // M2.2 #15: CaptureView(.auto)로 전환 예정
                }

                ModeCard(
                    title: "수동 입력",
                    subtitle: "양식·손글씨 카드는 직접 입력하세요",
                    iconName: "square.and.pencil",
                    color: .orange
                ) {
                    // M2.4 #17: ManualEntryView로 전환 예정
                }

                Spacer()

                Text("자동 인식이 실패해도 언제든 수동으로 전환할 수 있습니다.")
                    .font(.footnote)
                    .foregroundStyle(.tertiary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("카드 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { dismiss() }
                }
            }
        }
    }
}

private struct ModeCard: View {
    let title: String
    let subtitle: String
    let iconName: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: iconName)
                    .font(.title)
                    .frame(width: 56, height: 56)
                    .background(color.opacity(0.15))
                    .foregroundStyle(color)
                    .clipShape(RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    Text(subtitle)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(Color(.secondarySystemGroupedBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}
