import SwiftUI

struct ManualEntryView: View {
    @State var viewModel: ManualEntryViewModel
    let onSaved: () -> Void

    var body: some View {
        Form {
            Section {
                Image(uiImage: viewModel.originalImage)
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: 240)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Section("카드 유형") {
                Toggle("블렌드 카드", isOn: $viewModel.isBlend)
            }

            Section("카드 정보") {
                if viewModel.isBlend {
                    fieldRow("블렌드 이름", $viewModel.blendName)
                } else {
                    fieldRow("산지(국가)", $viewModel.originCountry)
                    fieldRow("산지(지역/농장)", $viewModel.originRegion)
                    fieldRow("품종", $viewModel.variety)
                }
                fieldRow("가공", $viewModel.process)
                fieldRow("로스팅", $viewModel.roastLevel)
                fieldRow("테이스팅 노트", $viewModel.tastingNotesText)
                fieldRow("카페", $viewModel.cafeName)
            }

            Section("나의 기록") {
                Stepper("별점: \(viewModel.userRating)", value: $viewModel.userRating, in: 0...5)
                TextField("메모", text: $viewModel.userMemo, axis: .vertical)
                    .lineLimit(2...5)
            }
        }
        .navigationTitle("수동 입력")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("저장") {
                    if viewModel.save() { onSaved() }
                }
                .fontWeight(.semibold)
            }
        }
    }

    @ViewBuilder
    private func fieldRow(_ title: String, _ binding: Binding<String>) -> some View {
        HStack(alignment: .top) {
            Text(title)
                .foregroundStyle(.secondary)
                .frame(width: 110, alignment: .leading)
            TextField(title, text: binding)
        }
    }
}
