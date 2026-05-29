import SwiftUI
import SwiftData

@main
struct NangmanNoteApp: App {
    let container: ModelContainer
    @State private var cardStore: CardStore

    init() {
        do {
            let container = try ModelContainer(
                for: CoffeeCard.self, Cafe.self, TastingNote.self, BlendComponent.self, TextLayer.self, StickerLayer.self
            )
            self.container = container
            _cardStore = State(initialValue: CardStore(context: container.mainContext))
        } catch {
            fatalError("ModelContainer 초기화 실패: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(cardStore)
        }
        .modelContainer(container)
    }
}
