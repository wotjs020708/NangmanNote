import Testing
import SwiftData
import Foundation
@testable import NangmanNote

@MainActor
struct SearchViewModelTests {
    private func makeStore() throws -> CardStore {
        let container = try ModelContainer(
            for: CoffeeCard.self, Cafe.self, TastingNote.self, BlendComponent.self,
            configurations: ModelConfiguration(isStoredInMemoryOnly: true)
        )
        return CardStore(context: ModelContext(container))
    }

    private func seedCards(_ store: CardStore) {
        let ethiopia = CoffeeCard()
        ethiopia.originCountry = "Ethiopia"
        ethiopia.variety = "Heirloom"
        ethiopia.processRaw = "washed"
        ethiopia.userRating = 5
        store.add(ethiopia)

        let honduras = CoffeeCard()
        honduras.originCountry = "Honduras"
        honduras.variety = "Geisha"
        honduras.processRaw = "natural"
        honduras.userRating = 4
        store.add(honduras)

        let cafe = Cafe(name: "스타벅스")
        let blend = CoffeeCard()
        blend.blendName = "햇살 블렌드"
        blend.cafe = cafe
        blend.userRating = 3
        let comp = BlendComponent(country: "Colombia", process: .washed, ratio: 60)
        blend.blendComponents.append(comp)
        store.add(blend)
    }

    @Test func emptyQuery_returnsAll() throws {
        let store = try makeStore()
        seedCards(store)
        let vm = SearchViewModel(store: store)
        #expect(vm.results.count == 3)
    }

    @Test func queryByCountry() throws {
        let store = try makeStore()
        seedCards(store)
        let vm = SearchViewModel(store: store)

        vm.query = "ethiopia"
        #expect(vm.results.count == 1)
        #expect(vm.results.first?.originCountry == "Ethiopia")
    }

    @Test func queryByVariety() throws {
        let store = try makeStore()
        seedCards(store)
        let vm = SearchViewModel(store: store)

        vm.query = "geisha"
        #expect(vm.results.count == 1)
        #expect(vm.results.first?.variety == "Geisha")
    }

    @Test func queryByBlendComponent() throws {
        let store = try makeStore()
        seedCards(store)
        let vm = SearchViewModel(store: store)

        vm.query = "colombia"
        #expect(vm.results.count == 1)
        #expect(vm.results.first?.blendName == "햇살 블렌드")
    }

    @Test func queryByCafeName() throws {
        let store = try makeStore()
        seedCards(store)
        let vm = SearchViewModel(store: store)

        vm.query = "스타벅스"
        #expect(vm.results.count == 1)
    }

    @Test func filterByCountry() throws {
        let store = try makeStore()
        seedCards(store)
        let vm = SearchViewModel(store: store)

        vm.selectedCountries = ["Honduras"]
        #expect(vm.results.count == 1)
        #expect(vm.results.first?.originCountry == "Honduras")
    }

    @Test func filterByProcess() throws {
        let store = try makeStore()
        seedCards(store)
        let vm = SearchViewModel(store: store)

        vm.selectedProcesses = [.washed]
        // Ethiopia(washed) + Colombia 블렌드 컴포넌트(washed)
        #expect(vm.results.count == 2)
    }

    @Test func filterByMinimumRating() throws {
        let store = try makeStore()
        seedCards(store)
        let vm = SearchViewModel(store: store)

        vm.minimumRating = 4
        #expect(vm.results.count == 2)  // Ethiopia(5), Honduras(4)

        vm.minimumRating = 5
        #expect(vm.results.count == 1)
    }

    @Test func combinedQueryAndFilter() throws {
        let store = try makeStore()
        seedCards(store)
        let vm = SearchViewModel(store: store)

        vm.query = "Ethiopia"
        vm.minimumRating = 5
        #expect(vm.results.count == 1)

        vm.minimumRating = 4
        vm.query = "Geisha"
        #expect(vm.results.count == 1)
    }

    @Test func availableCountriesIncludesBlendComponents() throws {
        let store = try makeStore()
        seedCards(store)
        let vm = SearchViewModel(store: store)

        let countries = vm.availableCountries
        #expect(countries.contains("Ethiopia"))
        #expect(countries.contains("Honduras"))
        #expect(countries.contains("Colombia"))
    }

    @Test func resetClearsAllFilters() throws {
        let store = try makeStore()
        seedCards(store)
        let vm = SearchViewModel(store: store)

        vm.selectedCountries = ["Ethiopia"]
        vm.selectedProcesses = [.washed]
        vm.minimumRating = 4
        #expect(vm.hasActiveFilters)

        vm.resetFilters()
        #expect(!vm.hasActiveFilters)
        #expect(vm.results.count == 3)
    }
}
