import SwiftUI
import PhotosUI
import UIKit

struct CaptureView: View {
    enum Source: String, CaseIterable, Identifiable {
        case camera = "카메라"
        case album = "앨범"
        var id: String { rawValue }
        var iconName: String {
            switch self {
            case .camera: "camera"
            case .album: "photo.on.rectangle"
            }
        }
    }

    let mode: InputMode
    let onPicked: (UIImage) -> Void
    @Environment(\.dismiss) private var dismiss

    @State private var pickerItem: PhotosPickerItem?
    @State private var showingCamera = false
    @State private var cameraAvailable: Bool = UIImagePickerController.isSourceTypeAvailable(.camera)
    @State private var loadError: String?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                Image(systemName: mode == .auto ? "wand.and.stars" : "square.and.pencil")
                    .font(.system(size: 60))
                    .foregroundStyle(mode == .auto ? Color.accentColor : .orange)

                Text(mode == .auto ? "자동 인식 모드" : "수동 입력 모드")
                    .font(.title2.bold())

                Text("카메라로 카드를 촬영하거나 앨범에서 선택하세요.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)

                Spacer()

                VStack(spacing: 12) {
                    if cameraAvailable {
                        Button {
                            showingCamera = true
                        } label: {
                            Label("카메라로 촬영", systemImage: "camera")
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 4)
                        }
                        .buttonStyle(.borderedProminent)
                        .controlSize(.large)
                    } else {
                        Text("이 기기에서는 카메라를 사용할 수 없습니다.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }

                    PhotosPicker(selection: $pickerItem, matching: .images) {
                        Label("앨범에서 선택", systemImage: "photo.on.rectangle")
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 4)
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                }

                if let loadError {
                    Text(loadError)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }
            }
            .padding()
            .navigationTitle("카드 사진")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") { dismiss() }
                }
            }
            .fullScreenCover(isPresented: $showingCamera) {
                CameraPickerRepresentable(
                    onPicked: { image in
                        showingCamera = false
                        onPicked(image)
                    },
                    onCancel: {
                        showingCamera = false
                    }
                )
                .ignoresSafeArea()
            }
            .onChange(of: pickerItem) { _, newItem in
                guard let newItem else { return }
                Task { await loadFromAlbum(newItem) }
            }
        }
    }

    private func loadFromAlbum(_ item: PhotosPickerItem) async {
        loadError = nil
        do {
            guard let data = try await item.loadTransferable(type: Data.self),
                  let image = UIImage(data: data) else {
                loadError = "이미지를 불러오지 못했습니다."
                return
            }
            onPicked(image)
        } catch {
            loadError = "앨범 접근 실패: \(error.localizedDescription)"
        }
    }
}
