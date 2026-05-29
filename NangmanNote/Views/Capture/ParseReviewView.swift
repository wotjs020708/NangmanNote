import SwiftUI

struct ParseReviewView: View {
    @State var viewModel: ParseReviewViewModel
    @State private var showingOCRRaw = false
    let onSaved: () -> Void
    let onSwitchToManual: () -> Void

    var body: some View {
        Form {
            Section {
                Image(uiImage: viewModel.originalImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            switch viewModel.stage {
            case .processing:
                Section {
                    HStack {
                        ProgressView()
                        Text("AI가 카드를 읽고 있습니다…")
                            .foregroundStyle(.secondary)
                    }
                }

            case .failed(let message):
                Section("처리 실패") {
                    Text(message)
                        .foregroundStyle(.red)
                    Button("재시도") {
                        Task { await viewModel.start() }
                    }
                    Button("수동 모드로 전환") {
                        onSwitchToManual()
                    }
                }

            case .ready:
                Section {
                    Picker("유형", selection: $viewModel.isBlend) {
                        Text("단일 원두").tag(false)
                        Text("블렌드").tag(true)
                    }
                    .pickerStyle(.segmented)
                } header: {
                    Text("카드 유형")
                } footer: {
                    Text(autoDetectedHint)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                if viewModel.isBlend {
                    Section("블렌드 정보") {
                        fieldRow("블렌드 이름", $viewModel.blendName, lowConfidence: viewModel.confidence < 0.5)
                    }

                    Section {
                        if viewModel.blendComponents.isEmpty {
                            Text("자동 감지된 컴포넌트가 없습니다. 사진을 다시 찍거나 수동 모드로 전환하세요.")
                                .font(.caption)
                                .foregroundStyle(.secondary)
                        } else {
                            ForEach(Array(viewModel.blendComponents.enumerated()), id: \.offset) { _, comp in
                                BlendComponentRow(component: comp)
                            }
                        }
                    } header: {
                        Text("블렌드 컴포넌트")
                    } footer: {
                        Text("M1.2 (#2) Foundation Models 적용 후 컴포넌트 인라인 편집 추가 예정.")
                            .font(.caption2)
                    }
                } else {
                    Section("추출된 정보") {
                        fieldRow("원두/블렌드", $viewModel.blendName, lowConfidence: viewModel.confidence < 0.5)
                        fieldRow("산지(국가)", $viewModel.originCountry, lowConfidence: viewModel.confidence < 0.5)
                        fieldRow("산지(지역/농장)", $viewModel.originRegion)
                        fieldRow("품종", $viewModel.variety)
                        fieldRow("가공", $viewModel.process)
                    }
                }

                Section("공통") {
                    fieldRow("로스팅", $viewModel.roastLevel)
                    fieldRow("테이스팅 노트", $viewModel.tastingNotesText)
                    fieldRow("카페", $viewModel.cafeName)
                }

                Section("나의 기록") {
                    Stepper("별점: \(viewModel.userRating)", value: $viewModel.userRating, in: 0...5)
                    TextField("메모", text: $viewModel.userMemo, axis: .vertical)
                        .lineLimit(2...5)
                }

                Section {
                    HStack {
                        Text("신뢰도")
                            .foregroundStyle(.secondary)
                        Spacer()
                        Text("\(Int(viewModel.confidence * 100))%")
                            .foregroundStyle(viewModel.confidence < 0.5 ? .orange : .secondary)
                            .font(.footnote.monospacedDigit())
                    }
                }
            }

            if !viewModel.ocrRawText.isEmpty {
                Section {
                    DisclosureGroup(isExpanded: $showingOCRRaw) {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Label("\(viewModel.ocrBlockCount) blocks", systemImage: "doc.text.magnifyingglass")
                                Spacer()
                                Text("avg \(Int(viewModel.ocrAvgConfidence * 100))%")
                                    .font(.caption.monospacedDigit())
                                    .foregroundStyle(.secondary)
                            }
                            .font(.caption)

                            Text(viewModel.ocrRawText)
                                .font(.system(.caption, design: .monospaced))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .textSelection(.enabled)
                        }
                        .padding(.vertical, 4)
                    } label: {
                        Label("Vision OCR 원문 (디버그)", systemImage: "text.viewfinder")
                            .font(.subheadline)
                    }
                } header: {
                    EmptyView()
                } footer: {
                    Text("OCR이 텍스트를 잘 잡았는데 폼이 비어 있다면, 파서(현재 Mock — #2에서 Foundation Models로 교체)가 원인입니다.")
                        .font(.caption2)
                }
            }
        }
        .navigationTitle("카드 확인")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("저장") {
                    if viewModel.save() { onSaved() }
                }
                .disabled(!isReady)
                .fontWeight(.semibold)
            }
        }
        .task { await viewModel.start() }
    }

    private var isReady: Bool {
        if case .ready = viewModel.stage { return true }
        return false
    }

    private var autoDetectedHint: String {
        if viewModel.blendComponents.count >= 2 {
            return "블렌드 자동 감지됨 (컴포넌트 \(viewModel.blendComponents.count)개). 토글로 변경 가능."
        }
        if !viewModel.blendName.isEmpty {
            return "블렌드 이름 감지됨. 토글로 변경 가능."
        }
        return "단일 원두로 감지됨. 토글로 변경 가능."
    }

    @ViewBuilder
    private func fieldRow(_ title: String, _ binding: Binding<String>, lowConfidence: Bool = false) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundStyle(.secondary)
                .frame(width: 110, alignment: .leading)
            TextField(title, text: binding)
                .foregroundStyle(lowConfidence && !binding.wrappedValue.isEmpty ? .orange : .primary)
        }
    }
}

private struct BlendComponentRow: View {
    let component: ParsedBlendComponent

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(component.country)
                    .font(.subheadline.weight(.medium))
                Spacer()
                if let ratio = component.ratio {
                    Text("\(ratio)%")
                        .font(.subheadline.monospacedDigit())
                        .foregroundStyle(.tint)
                }
            }
            HStack(spacing: 8) {
                if let variety = component.variety {
                    Label(variety, systemImage: "leaf")
                }
                if let process = component.process {
                    Label(process, systemImage: "drop")
                }
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 2)
    }
}
