import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            Text("컬렉션")
                .tabItem { Label("컬렉션", systemImage: "square.grid.2x2") }
            Text("지도")
                .tabItem { Label("지도", systemImage: "map") }
            Text("설정")
                .tabItem { Label("설정", systemImage: "gear") }
        }
    }
}

#Preview {
    RootView()
}
