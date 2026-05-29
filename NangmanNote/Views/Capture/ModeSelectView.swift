import SwiftUI
import UIKit

struct ModeSelectView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(CardStore.self) private var cardStore
    @State private var path = NavigationPath()

    var body: some View {
        NavigationStack(path: $path) {
            VStack(spacing: 16) {
                Spacer()

                ModeCard(
                    title: "자동 인식",
                    subtitle: "AI가 카드 정보를 자동으로 채웁니다",
                    iconName: "wand.and.stars",
                    color: .accentColor
                ) {
                    path.append(InputMode.auto)
                }

                ModeCard(
                    title: "수동 입력",
                    subtitle: "양식·손글씨 카드는 직접 입력하세요",
                    iconName: "square.and.pencil",
                    color: .orange
                ) {
                    path.append(InputMode.manual)
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
            .navigationDestination(for: InputMode.self) { mode in
                CaptureView(mode: mode) { image in
                    path.append(CapturedSelection(image: image, mode: mode))
                }
            }
            .navigationDestination(for: CapturedSelection.self) { selection in
                destinationView(for: selection)
                    .id(selection.id)
            }
        }
    }

    @ViewBuilder
    private func destinationView(for selection: CapturedSelection) -> some View {
        if selection.mode == .auto {
            ParseReviewView(
                viewModel: ParseReviewViewModel(
                    image: selection.image,
                    preprocessor: ImagePreprocessor(),
                    ocr: OCRService(),
                    parser: ParsingService(),
                    cardStore: cardStore
                ),
                onSaved: { dismiss() },
                onSwitchToManual: {
                    path.append(CapturedSelection(image: selection.image, mode: .manual))
                }
            )
        } else {
            ManualEntryView(
                viewModel: ManualEntryViewModel(
                    image: selection.image,
                    cardStore: cardStore
                ),
                onSaved: { dismiss() }
            )
        }
    }
}

struct CapturedSelection: Hashable {
    let id: UUID = UUID()
    let image: UIImage
    let mode: InputMode

    static func == (lhs: Self, rhs: Self) -> Bool { lhs.id == rhs.id }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
}

extension InputMode: Identifiable {
    public var id: String { rawValue }
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
