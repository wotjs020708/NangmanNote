import SwiftUI

/// 카드의 양면(앞/뒷면)을 3D rotation 애니메이션으로 전환하는 컨테이너.
/// 탭으로 토글, 외부에서 `showingFront` 바인딩.
struct FlipContainer<Front: View, Back: View>: View {
    @Binding var showingFront: Bool
    let front: Front
    let back: Back

    init(
        showingFront: Binding<Bool>,
        @ViewBuilder front: () -> Front,
        @ViewBuilder back: () -> Back
    ) {
        self._showingFront = showingFront
        self.front = front()
        self.back = back()
    }

    var body: some View {
        ZStack {
            front
                .opacity(showingFront ? 1 : 0)
                .rotation3DEffect(.degrees(showingFront ? 0 : 180), axis: (x: 0, y: 1, z: 0))

            back
                .opacity(showingFront ? 0 : 1)
                .rotation3DEffect(.degrees(showingFront ? -180 : 0), axis: (x: 0, y: 1, z: 0))
        }
        .animation(.spring(response: 0.55, dampingFraction: 0.8), value: showingFront)
        .onTapGesture { showingFront.toggle() }
        .accessibilityAddTraits(.isButton)
        .accessibilityLabel(showingFront ? "앞면. 탭하여 뒤집기" : "뒷면. 탭하여 뒤집기")
    }
}
