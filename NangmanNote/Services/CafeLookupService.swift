import Foundation
import MapKit
import CoreLocation

final class CafeLookupService: CafeLookupServicing {
    private let maxResults: Int
    private let searchRadiusMeters: CLLocationDistance

    init(maxResults: Int = 5, searchRadiusMeters: CLLocationDistance = 5_000) {
        self.maxResults = maxResults
        self.searchRadiusMeters = searchRadiusMeters
    }

    func search(name: String, near: CLLocationCoordinate2D?) async throws -> [CafeCandidate] {
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "\(name) 카페"
        request.resultTypes = .pointOfInterest

        if let near {
            request.region = MKCoordinateRegion(
                center: near,
                latitudinalMeters: searchRadiusMeters,
                longitudinalMeters: searchRadiusMeters
            )
        }

        let search = MKLocalSearch(request: request)
        let response = try await search.start()

        let anchor = near.map { CLLocation(latitude: $0.latitude, longitude: $0.longitude) }

        let candidates = response.mapItems.prefix(maxResults).map { item -> CafeCandidate in
            let coord = item.location.coordinate
            let address = item.address.flatMap { $0.shortAddress ?? $0.fullAddress }

            let distance: CLLocationDistance? = anchor.map {
                $0.distance(from: item.location)
            }

            return CafeCandidate(
                name: item.name ?? name,
                coordinate: coord,
                address: address,
                distance: distance
            )
        }

        return candidates.sorted { lhs, rhs in
            switch (lhs.distance, rhs.distance) {
            case let (l?, r?): return l < r
            case (.some, .none): return true
            case (.none, .some): return false
            case (.none, .none): return false
            }
        }
    }
}

struct MockCafeLookupService: CafeLookupServicing {
    let fixedCandidates: [CafeCandidate]

    init(fixedCandidates: [CafeCandidate] = []) {
        self.fixedCandidates = fixedCandidates
    }

    func search(name: String, near: CLLocationCoordinate2D?) async throws -> [CafeCandidate] {
        fixedCandidates
    }
}
