import SwiftUI

struct RootView: View {
    var body: some View {
        TabView {
            CollectionView()
                .tabItem { Label("컬렉션", systemImage: "square.grid.2x2") }
            MapTabView()
                .tabItem { Label("지도", systemImage: "map") }
            SettingsView()
                .tabItem { Label("설정", systemImage: "gear") }
        }
    }
}
