import SwiftUI
import SwiftData

@main
struct NangmanNoteApp: App {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(
                for: CoffeeCard.self, Cafe.self, TastingNote.self
            )
        } catch {
            fatalError("ModelContainer 초기화 실패: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            RootView()
        }
        .modelContainer(container)
    }
}
