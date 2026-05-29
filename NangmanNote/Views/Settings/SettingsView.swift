import SwiftUI

struct SettingsView: View {
    @Environment(CardStore.self) private var store
    @State private var exportURL: URL?
    @State private var exportError: String?
    @State private var isExporting = false

    private var appVersion: String {
        let v = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let b = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(v) (\(b))"
    }

    var body: some View {
        NavigationStack {
            List {
                aboutSection
                dataSection
                creditSection
            }
            .navigationTitle("설정")
            .alert(
                "내보내기 실패",
                isPresented: Binding(
                    get: { exportError != nil },
                    set: { if !$0 { exportError = nil } }
                ),
                actions: { Button("확인", role: .cancel) {} },
                message: { Text(exportError ?? "") }
            )
        }
    }

    private var aboutSection: some View {
        Section {
            VStack(alignment: .leading, spacing: 6) {
                Text("낭만 노트")
                    .font(.title3.bold())
                Text("한 잔의 낭만을 모읍니다")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 6)
        }
    }

    private var dataSection: some View {
        Section {
            HStack {
                Label("카드", systemImage: "square.grid.2x2.fill")
                Spacer()
                Text("\(store.cards.count)장")
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }

            Button {
                Task { await runExport() }
            } label: {
                if isExporting {
                    HStack { ProgressView(); Text("내보내는 중…") }
                } else {
                    Label("JSON으로 내보내기", systemImage: "arrow.down.doc")
                }
            }
            .disabled(isExporting || store.cards.isEmpty)

            if let url = exportURL {
                ShareLink(item: url, preview: SharePreview(url.lastPathComponent, image: Image(systemName: "doc.text"))) {
                    Label("공유", systemImage: "square.and.arrow.up")
                        .foregroundStyle(.tint)
                }
            }
        } header: {
            Text("데이터")
        } footer: {
            Text("모든 데이터는 기기 안에만 저장됩니다. 인터넷·서버를 사용하지 않습니다.")
        }
    }

    private var creditSection: some View {
        Section("앱 정보") {
            HStack {
                Text("버전")
                Spacer()
                Text(appVersion)
                    .foregroundStyle(.secondary)
                    .monospacedDigit()
            }
            Link(destination: URL(string: "https://github.com/wotjs020708/NangmanNote")!) {
                Label("GitHub 저장소", systemImage: "link")
            }
            HStack {
                Label("AI 엔진", systemImage: "wand.and.stars")
                Spacer()
                Text("Apple Foundation Models")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
    }

    private func runExport() async {
        isExporting = true
        defer { isExporting = false }

        do {
            let url = try CardExporter.exportJSON(Array(store.cards))
            exportURL = url
        } catch {
            exportError = error.localizedDescription
        }
    }
}
