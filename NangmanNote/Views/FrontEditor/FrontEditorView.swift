import SwiftUI
import SwiftData

struct FrontEditorView: View {
    @Bindable var card: CoffeeCard
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var context

    @State private var addingText = false
    @State private var newTextContent = ""
    @State private var newTextFont: TextFontStyle = .body
    @State private var newTextColor: String = "#000000"

    @State private var canvasSize: CGSize = .zero

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                preview
                    .padding(.horizontal)

                presetPicker

                actionBar
            }
            .padding(.top, 8)
            .navigationTitle("앞면 꾸미기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("완료") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $addingText) {
                addTextSheet
            }
        }
    }

    private var preview: some View {
        GeometryReader { geo in
            ZStack {
                card.frontBackground.background()
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                ForEach(card.textLayers) { layer in
                    DraggableTextLayer(layer: layer, canvasSize: geo.size)
                }

                if card.textLayers.isEmpty {
                    Text("탭으로 텍스트·이모지 추가")
                        .font(.caption)
                        .foregroundStyle(card.frontBackground.preferredTextColor.opacity(0.5))
                }
            }
            .onAppear { canvasSize = geo.size }
            .onChange(of: geo.size) { _, new in canvasSize = new }
        }
        .aspectRatio(0.72, contentMode: .fit)
    }

    private var presetPicker: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("배경")
                .font(.caption.bold())
                .foregroundStyle(.secondary)
                .padding(.horizontal)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 10) {
                    ForEach(FrontBackgroundPreset.allCases) { preset in
                        presetSwatch(preset)
                    }
                }
                .padding(.horizontal)
            }
        }
    }

    private var actionBar: some View {
        HStack(spacing: 12) {
            Button {
                newTextContent = ""
                newTextFont = .body
                newTextColor = "#000000"
                addingText = true
            } label: {
                Label("텍스트 추가", systemImage: "textformat")
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal)
        .padding(.bottom, 12)
    }

    private func presetSwatch(_ preset: FrontBackgroundPreset) -> some View {
        let isSelected = card.frontBackground == preset
        return VStack(spacing: 4) {
            preset.background()
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(width: 52, height: 64)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(isSelected ? Color.accentColor : Color.clear, lineWidth: 2.5)
                }
            Text(preset.label)
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                card.frontBackground = preset
            }
        }
    }

    @ViewBuilder
    private var addTextSheet: some View {
        NavigationStack {
            Form {
                Section("내용") {
                    TextField("한 줄 메모", text: $newTextContent, axis: .vertical)
                        .lineLimit(1...3)
                }
                Section("폰트") {
                    Picker("폰트", selection: $newTextFont) {
                        ForEach(TextFontStyle.allCases, id: \.self) { style in
                            Text(style.label).font(style.font).tag(style)
                        }
                    }
                    .pickerStyle(.segmented)
                }
                Section("색상") {
                    HStack(spacing: 12) {
                        ForEach(TextColorPreset.presets) { preset in
                            Circle()
                                .fill(preset.color)
                                .frame(width: 30, height: 30)
                                .overlay {
                                    Circle()
                                        .stroke(newTextColor == preset.id ? Color.accentColor : Color.gray.opacity(0.3), lineWidth: 2)
                                }
                                .overlay {
                                    if newTextColor == preset.id {
                                        Image(systemName: "checkmark")
                                            .font(.caption.bold())
                                            .foregroundStyle(preset.color == .white ? .black : .white)
                                    }
                                }
                                .onTapGesture { newTextColor = preset.id }
                        }
                    }
                }
            }
            .navigationTitle("텍스트 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { addingText = false }
                }
                ToolbarItem(placement: .topBarTrailing) {
                    Button("추가") {
                        let layer = TextLayer(
                            content: newTextContent,
                            fontStyle: newTextFont,
                            hexColor: newTextColor
                        )
                        layer.card = card
                        card.textLayers.append(layer)
                        context.insert(layer)
                        addingText = false
                    }
                    .fontWeight(.semibold)
                    .disabled(newTextContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}

/// 드래그 가능한 텍스트 레이어. positionX/Y는 0~1 비율로 저장.
private struct DraggableTextLayer: View {
    @Bindable var layer: TextLayer
    let canvasSize: CGSize
    @Environment(\.modelContext) private var context

    @State private var dragOffset: CGSize = .zero
    @State private var showingDelete = false

    var body: some View {
        Text(layer.content)
            .font(layer.fontStyle.font)
            .foregroundStyle(layer.color)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .position(
                x: layer.positionX * canvasSize.width + dragOffset.width,
                y: layer.positionY * canvasSize.height + dragOffset.height
            )
            .gesture(
                DragGesture()
                    .onChanged { dragOffset = $0.translation }
                    .onEnded { value in
                        let newX = (layer.positionX * canvasSize.width + value.translation.width) / canvasSize.width
                        let newY = (layer.positionY * canvasSize.height + value.translation.height) / canvasSize.height
                        layer.positionX = min(max(newX, 0.05), 0.95)
                        layer.positionY = min(max(newY, 0.05), 0.95)
                        dragOffset = .zero
                    }
            )
            .onLongPressGesture(minimumDuration: 0.5) {
                showingDelete = true
            }
            .confirmationDialog("삭제하시겠습니까?", isPresented: $showingDelete) {
                Button("삭제", role: .destructive) {
                    if let card = layer.card,
                       let idx = card.textLayers.firstIndex(where: { $0.id == layer.id }) {
                        card.textLayers.remove(at: idx)
                    }
                    context.delete(layer)
                }
                Button("취소", role: .cancel) {}
            }
    }
}
