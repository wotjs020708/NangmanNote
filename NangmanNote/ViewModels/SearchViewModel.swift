import Foundation
import Observation

@Observable
@MainActor
final class SearchViewModel {
    var query: String = ""
    var selectedNotes: Set<String> = []
    var selectedCountries: Set<String> = []
    var selectedProcesses: Set<ProcessMethod> = []
    var minimumRating: Int = 0

    private let store: CardStore

    init(store: CardStore) {
        self.store = store
    }

    var results: [CoffeeCard] {
        var filtered = store.cards

        let q = query.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        if !q.isEmpty {
            filtered = filtered.filter { Self.matchesQuery($0, query: q) }
        }

        if !selectedNotes.isEmpty {
            let normalizedNotes = Set(selectedNotes.map { $0.lowercased() })
            filtered = filtered.filter { card in
                let cardNotes = Set(card.tastingNotes.map { $0.label.lowercased() })
                return !cardNotes.intersection(normalizedNotes).isEmpty
            }
        }

        if !selectedCountries.isEmpty {
            filtered = filtered.filter { card in
                if let country = card.originCountry, selectedCountries.contains(country) {
                    return true
                }
                return card.blendComponents.contains { selectedCountries.contains($0.country) }
            }
        }

        if !selectedProcesses.isEmpty {
            filtered = filtered.filter { card in
                if let process = card.process, selectedProcesses.contains(process) {
                    return true
                }
                return card.blendComponents.contains { comp in
                    guard let p = comp.process else { return false }
                    return selectedProcesses.contains(p)
                }
            }
        }

        if minimumRating > 0 {
            filtered = filtered.filter { ($0.userRating ?? 0) >= minimumRating }
        }

        return filtered
    }

    var availableNotes: [String] {
        var seen = Set<String>()
        var ordered: [String] = []
        for card in store.cards {
            for note in card.tastingNotes where !seen.contains(note.label.lowercased()) {
                seen.insert(note.label.lowercased())
                ordered.append(note.label)
            }
        }
        return ordered.sorted()
    }

    var availableCountries: [String] {
        var seen = Set<String>()
        for card in store.cards {
            if let c = card.originCountry { seen.insert(c) }
            for comp in card.blendComponents { seen.insert(comp.country) }
        }
        return Array(seen).sorted()
    }

    func toggle(note: String) {
        if selectedNotes.contains(note) { selectedNotes.remove(note) } else { selectedNotes.insert(note) }
    }

    func toggle(country: String) {
        if selectedCountries.contains(country) { selectedCountries.remove(country) } else { selectedCountries.insert(country) }
    }

    func toggle(process: ProcessMethod) {
        if selectedProcesses.contains(process) { selectedProcesses.remove(process) } else { selectedProcesses.insert(process) }
    }

    func resetFilters() {
        selectedNotes.removeAll()
        selectedCountries.removeAll()
        selectedProcesses.removeAll()
        minimumRating = 0
    }

    var hasActiveFilters: Bool {
        !selectedNotes.isEmpty || !selectedCountries.isEmpty || !selectedProcesses.isEmpty || minimumRating > 0
    }

    static func matchesQuery(_ card: CoffeeCard, query: String) -> Bool {
        let fields: [String?] = [
            card.blendName,
            card.originCountry, card.originRegion, card.variety,
            card.cafe?.name, card.userMemo
        ]
        if fields.compactMap({ $0 }).contains(where: { $0.lowercased().contains(query) }) {
            return true
        }
        if card.tastingNotes.contains(where: { $0.label.lowercased().contains(query) }) {
            return true
        }
        if card.blendComponents.contains(where: {
            $0.country.lowercased().contains(query)
                || ($0.region?.lowercased().contains(query) ?? false)
                || ($0.variety?.lowercased().contains(query) ?? false)
        }) {
            return true
        }
        return false
    }
}
